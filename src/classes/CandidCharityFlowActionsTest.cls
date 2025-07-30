@isTest
public class CandidCharityFlowActionsTest {
    
    @testSetup
    static void setup() {
        // Create test custom settings
        CandidCharity_Settings__c settings = new CandidCharity_Settings__c();
        settings.Name = 'Default';
        settings.Charity_Check_API_Key__c = 'test-api-key';
        insert settings;
    }
    
    @isTest
    static void testSearchSingleOrganization_Success() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new CandidCharityTest.MockHttpResponseGenerator());
        
        // Test input
        CandidCharityFlowActions.SearchInput input = new CandidCharityFlowActions.SearchInput();
        input.ein = '53-0242652';  // Use mock data EIN
        
        Test.startTest();
        List<CandidCharityFlowActions.SearchOutput> results = 
            CandidCharityFlowActions.searchSingleOrganization(new List<CandidCharityFlowActions.SearchInput>{input});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size());
        CandidCharityFlowActions.SearchOutput output = results[0];
        System.assertEquals(true, output.success);
        System.assertEquals('The Nature Conservancy', output.organizationName);
        System.assertEquals('53-0242652', output.ein);
        System.assertEquals('Arlington', output.city);
        System.assertEquals('VA', output.state);
        System.assertEquals(true, output.isVerified);
        System.assertNotEquals(null, output.address);
        System.assertEquals('22203', output.zipCode);
    }
    
    @isTest
    static void testSearchSingleOrganization_BlankEIN() {
        CandidCharityFlowActions.SearchInput input = new CandidCharityFlowActions.SearchInput();
        input.ein = '';  // Blank EIN
        
        Test.startTest();
        List<CandidCharityFlowActions.SearchOutput> results = 
            CandidCharityFlowActions.searchSingleOrganization(new List<CandidCharityFlowActions.SearchInput>{input});
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals(1, results.size());
        CandidCharityFlowActions.SearchOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assert(output.errorMessage.contains('EIN is required'));
    }
    
    @isTest
    static void testSearchSingleOrganization_NotFound() {
        // Set up mock for 404 response
        Test.setMock(HttpCalloutMock.class, new CandidCharityTest.MockHttpResponseGenerator(404, null));
        
        CandidCharityFlowActions.SearchInput input = new CandidCharityFlowActions.SearchInput();
        input.ein = '99-9999999';  // Non-existent EIN
        
        Test.startTest();
        List<CandidCharityFlowActions.SearchOutput> results = 
            CandidCharityFlowActions.searchSingleOrganization(new List<CandidCharityFlowActions.SearchInput>{input});
        Test.stopTest();
        
        // Verify not found handling
        System.assertEquals(1, results.size());
        CandidCharityFlowActions.SearchOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assert(output.errorMessage.contains('No organization found'));
    }
    
    @isTest
    static void testSearchSingleOrganization_APIError() {
        // Set up mock for server error
        Test.setMock(HttpCalloutMock.class, new CandidCharityTest.MockHttpResponseGenerator(500, null));
        
        CandidCharityFlowActions.SearchInput input = new CandidCharityFlowActions.SearchInput();
        input.ein = '53-0242652';
        
        Test.startTest();
        List<CandidCharityFlowActions.SearchOutput> results = 
            CandidCharityFlowActions.searchSingleOrganization(new List<CandidCharityFlowActions.SearchInput>{input});
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals(1, results.size());
        CandidCharityFlowActions.SearchOutput output = results[0];
        System.assertEquals(false, output.success);
        System.assertNotEquals(null, output.errorMessage);
    }
    
    @isTest
    static void testBuildShippingStreet() {
        // Test helper method through the public interface
        // Since buildShippingStreet is private, we test it indirectly through the search method
        
        // This test verifies that address building works correctly
        Test.setMock(HttpCalloutMock.class, new CandidCharityTest.MockHttpResponseGenerator());
        
        CandidCharityFlowActions.SearchInput input = new CandidCharityFlowActions.SearchInput();
        input.ein = '53-0242652';
        
        Test.startTest();
        List<CandidCharityFlowActions.SearchOutput> results = 
            CandidCharityFlowActions.searchSingleOrganization(new List<CandidCharityFlowActions.SearchInput>{input});
        Test.stopTest();
        
        // The mock data should return "4245 N Fairfax Dr" + " " + "Ste 100"
        CandidCharityFlowActions.SearchOutput output = results[0];
        System.assertEquals(true, output.success);
        System.assertEquals('4245 N Fairfax Dr Ste 100', output.address);
    }
}
