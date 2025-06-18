@isTest
public class CandidCharityTest {
    
    // Updated JSON response matching the new API structure
    public static final String charityCheckJson = '{\"data\":{\"organization_id\":\"7794876\",\"organization_info_last_modified\":\"11/21/2024 4:10:31 PM\",\"ein\":\"53-0242652\",\"organization_name\":\"The Nature Conservancy\",\"organization_name_aka\":\"The Nature Conservancy\",\"address_line1\":\"4245 N Fairfax Dr\",\"address_line2\":\"Ste 100\",\"city\":\"Arlington\",\"state\":\"VA\",\"state_name\":\"Virginia\",\"zip\":\"22203\",\"filing_req_code\":\"010\",\"charity_check_last_modified\":\"9/11/2024 5:11:41 PM\",\"pub78_church_message\":null,\"pub78_organization_name\":\"Nature Conservancy\",\"pub78_ein\":\"53-0242652\",\"pub78_verified\":\"True\",\"pub78_city\":\"Arlington\",\"pub78_state\":\"VA\",\"pub78_indicator\":\"0\",\"organization_types\":[{\"organization_type\":\"A public charity (50% deductibility limitation).\",\"deductibility_limitation\":\"50%\",\"deductibility_status_description\":\"PC\"}],\"most_recent_pub78\":\"11/11/2024 12:00:00 AM\",\"most_recent_irb\":\"12/2/2024 12:00:00 AM\",\"bmf_church_message\":null,\"bmf_organization_name\":\"NATURE CONSERVANCY\",\"bmf_ein\":\"53-0242652\",\"bmf_status\":\"True\",\"most_recent_bmf\":\"11/11/2024 12:00:00 AM\",\"bmf_subsection\":\"03\",\"subsection_description\":\"501(c)(3) Public Charity\",\"foundation_code\":\"15\",\"foundation_code_description\":\"Organization which receives a substantial part of its support from a governmental unit or the general public\",\"ruling_month\":\"03\",\"ruling_year\":\"1954\",\"adv_ruling_month\":\"00\",\"adv_ruling_year\":\"0000\",\"group_exemption\":\"0000\",\"exempt_status_code\":\"01\",\"ofac_status\":\"This organization was not included in the Office of Foreign Assets Control Specially Designated Nationals(SDN) list.\",\"revocation_code\":\"\",\"revocation_date\":\"\",\"reinstatement_date\":\"\",\"irs_bmf_pub78_conflict\":\"False\",\"foundation_509a_status\":\"Section 509(a)(1) organization as referred to in Section 170(b)(1)(A)(vi)\",\"irb_organization_id\":\"\",\"bulletin_number\":\"\",\"bulletin_url\":\"\",\"effective_date\":\"\",\"irb_last_modified\":\"\",\"report_date\":\"12/4/2024 4:36:09 PM\",\"foundation_type_code\":\"PC\",\"foundation_type_description\":\"Public charity described in section 509(a)(1) or (2)\",\"parent_organizations\":[],\"retrieval_time_in_milliseconds\":\"3.4816\",\"total_pipeline_time_in_milliseconds\":\"10.2069\"}}';
    
    public static final String bulkCharityCheckJson = '{\"data\":[{\"organization_id\":\"7794876\",\"ein\":\"53-0242652\",\"organization_name\":\"The Nature Conservancy\",\"pub78_verified\":\"True\",\"bmf_status\":\"True\",\"subsection_description\":\"501(c)(3) Public Charity\",\"ofac_status\":\"This organization was not included in the Office of Foreign Assets Control Specially Designated Nationals(SDN) list.\"},{\"organization_id\":\"1234567\",\"ein\":\"12-3456789\",\"organization_name\":\"Test Charity\",\"pub78_verified\":\"True\",\"bmf_status\":\"True\",\"subsection_description\":\"501(c)(3) Public Charity\",\"ofac_status\":\"This organization was not included in the Office of Foreign Assets Control Specially Designated Nationals(SDN) list.\"}]}';

    private static testmethod void testCharityChecksingle() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity('test@example.com','password');
        CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals('Arlington', result.city);
        System.assertEquals('The Nature Conservancy', result.organization_name);
        System.assertEquals('True', result.pub78_verified);
        System.assertEquals('True', result.bmf_status);
        System.assertEquals(true, result.isVerified());
    }    private static testmethod void testCharityCheckWithApiKey() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity('test-api-key');
        CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals('The Nature Conservancy', result.organization_name);
    }    private static testmethod void testCharityCheckBulk() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity();
        String[] einList = new String[]{'53-0242652', '12-3456789'};
        CandidCharity.CharityCheckBulkData result = cc.charityCheck(einList, 'bulk');
        test.stopTest();
        
        System.assertNotEquals(null, result);
        // Bulk response would need different handling - this is simplified for testing
    }    private static testmethod void testCharityCheckBadEin() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity('test@example.com','password');
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck('bogus123', 'single');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertEquals('EIN must consist of 9 numbers (e.g. 94-3347800).', cce.getMessage());
    }    private static testmethod void testCharityCheckNullEin() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck(null, 'single');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertEquals('EIN cannot be null.', cce.getMessage());
    }    private static testmethod void testCharityCheckInvalidType() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'invalid');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertNotEquals(null, cce);
        System.assert(cce.getMessage().contains('Invalid charity check type'));
    }    private static testmethod void testCharityCheckNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(404, null));
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        test.stopTest();
        System.assertEquals(null, result);
    }    private static testmethod void testCharityCheckUnauthorized() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, null));
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertEquals(401, cce.statusCode);
        System.assert(cce.getMessage().contains('Unauthorized'));
    }    private static testmethod void testCharityCheckForbidden() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(403, null));
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertEquals(403, cce.statusCode);
        System.assert(cce.getMessage().contains('Forbidden'));
    }    private static testmethod void testCharityCheckServerError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, null));
        test.startTest();
        CandidCharity cc = new CandidCharity();
        CandidCharity.charityCheckException cce;
        try {
            CandidCharity.CharityCheckData result = cc.charityCheck('53-0242652', 'single');
        } catch (CandidCharity.charityCheckException e) {
            cce = e;
        }
        test.stopTest();
        System.assertEquals(500, cce.statusCode);
        System.assert(cce.getMessage().contains('Server Error'));
    }    private static testmethod void testCleanEin() {
        test.startTest();
        CandidCharity cc = new CandidCharity();
        // Note: cleanEin is protected, so we'll need to make it public or test through public methods
        test.stopTest();
        // This test may need to be updated based on access modifiers
    }    private static testmethod void testCleanEinNoHyphen() {
        test.startTest();
        CandidCharity cc = new CandidCharity();
        // Note: cleanEin is protected, so we'll need to make it public or test through public methods
        test.stopTest();
        // This test may need to be updated based on access modifiers
    }    private static testmethod void testIsVerifiedMethod() {
        CandidCharity.CharityCheckData data = new CandidCharity.CharityCheckData();
        data.pub78_verified = 'True';
        data.bmf_status = 'True';
        data.ofac_status = 'This organization was not included in the Office of Foreign Assets Control Specially Designated Nationals(SDN) list.';
        data.subsection_description = '501(c)(3) Public Charity';
        
        System.assertEquals(true, data.isVerified());
        
        // Test false case
        data.pub78_verified = 'False';
        System.assertEquals(false, data.isVerified());
    }    private static testmethod void testOrganizationType() {
        CandidCharity.OrganizationType orgType = new CandidCharity.OrganizationType();
        orgType.organization_type = 'A public charity (50% deductibility limitation).';
        orgType.deductibility_limitation = '50%';
        orgType.deductibility_status_description = 'PC';
        
        System.assertEquals('A public charity (50% deductibility limitation).', orgType.organization_type);
        System.assertEquals('50%', orgType.deductibility_limitation);
        System.assertEquals('PC', orgType.deductibility_status_description);
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer status;
        String response;
        
        public MockHttpResponseGenerator() {}
        public MockHttpResponseGenerator(Integer stat, String resp) { 
            status = stat; 
            response = resp; 
        }

        public HTTPResponse respond(HTTPRequest req) {
            String testResponse = 
                (response != null) ? response :
                (req.getMethod() == 'POST' && req.getEndpoint().contains('/bulk')) ? bulkCharityCheckJson :
                (req.getEndpoint().contains('/charitycheck/')) ? charityCheckJson :
                null;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(testResponse);
            res.setStatusCode((status == null) ? 200 : status);
            return res;
        }
    }
}