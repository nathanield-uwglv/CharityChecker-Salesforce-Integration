/**
 * Invocable Apex method for getting charity details for Account creation
 */
public class CandidCharityDetailsAction {
    
    /**
     * Input parameters for the charity check flow action
     */
    public class CharityCheckInput {
        @InvocableVariable(label='EIN Number' description='The EIN to check (e.g., 13-1837418)' required=true)
        public String ein;
        
        @InvocableVariable(label='Check Type' description='Type of check: single or pdf' required=false)
        public String checkType = 'single';
    }
    
    /**
     * Output results for the charity check flow action - optimized for Account creation
     */
    public class CharityCheckOutput {
        @InvocableVariable(label='Account Name' description='Name of the organization for Account.Name')
        public String accountName;
        
        @InvocableVariable(label='EIN' description='The EIN for Account.ep01__EIN__c')
        public String ein;
        
        @InvocableVariable(label='Phone' description='Phone number for Account.Phone')
        public String phone;
        
        @InvocableVariable(label='Fax' description='Fax number for Account.Fax')
        public String fax;
        
        @InvocableVariable(label='Website' description='Website URL for Account.Website')
        public String website;
        
        @InvocableVariable(label='Shipping Street' description='Street address for Account.ShippingStreet')
        public String shippingStreet;
        
        @InvocableVariable(label='Shipping City' description='City for Account.ShippingCity')
        public String shippingCity;
        
        @InvocableVariable(label='Shipping State' description='State for Account.ShippingState')
        public String shippingState;
        
        @InvocableVariable(label='Shipping Postal Code' description='Postal code for Account.ShippingPostalCode')
        public String shippingPostalCode;
        
        @InvocableVariable(label='Is Verified' description='Whether the charity is verified 501(c)(3)')
        public Boolean isVerified;
        
        @InvocableVariable(label='Success' description='Whether the API call was successful')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if the call failed')
        public String errorMessage;
        
        @InvocableVariable(label='Response JSON' description='Full JSON response for debugging')
        public String responseJson;
    }
    
    /**
     * Get detailed charity information for Account creation/update
     */
    @InvocableMethod(label='Get Charity Details for Account' description='Get detailed charity information formatted for Account fields')
    public static List<CharityCheckOutput> getCharityDetails(List<CharityCheckInput> inputs) {
        List<CharityCheckOutput> outputs = new List<CharityCheckOutput>();
        
        for (CharityCheckInput input : inputs) {
            CharityCheckOutput output = new CharityCheckOutput();
            
            try {
                // Create CandidCharity instance (uses Custom Settings)
                CandidCharity cc = new CandidCharity();
                
                // Call the API
                CandidCharity.CharityCheckData result = cc.charityCheck(input.ein, input.checkType);
                
                if (result != null) {
                    // Map Candid fields to Account fields
                    output.accountName = result.organization_name;
                    output.ein = result.ein;
                    output.phone = null; // Candid doesn't provide phone in charity check
                    output.fax = null;   // Candid doesn't provide fax in charity check
                    output.website = null; // Candid doesn't provide website in charity check
                    
                    // Map address fields
                    output.shippingStreet = buildShippingStreet(result.address_line1, result.address_line2);
                    output.shippingCity = result.city;
                    output.shippingState = result.state;
                    output.shippingPostalCode = result.zip;
                    
                    output.isVerified = result.isVerified();
                    output.success = true;
                    output.errorMessage = null;
                    output.responseJson = result.responseJson;
                } else {
                    // Handle 404 case
                    output.success = false;
                    output.errorMessage = 'Organization not found with EIN: ' + input.ein;
                    output.ein = input.ein;
                }
                
            } catch (Exception e) {
                // Handle errors
                output.success = false;
                output.errorMessage = e.getMessage();
                output.ein = input.ein;
                
                // Log the error for debugging
                System.debug('CandidCharity Flow Error: ' + e.getMessage());
            }
            
            outputs.add(output);
        }
        
        return outputs;
    }
    
    /**
     * Helper method to build shipping street from address lines
     */
    @TestVisible
    private static String buildShippingStreet(String addressLine1, String addressLine2) {
        if (String.isBlank(addressLine1)) return null;
        if (String.isBlank(addressLine2)) return addressLine1;
        return addressLine1 + '\n' + addressLine2;
    }
}
