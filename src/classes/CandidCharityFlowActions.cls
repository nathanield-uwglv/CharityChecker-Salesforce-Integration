/**
 * Invocable Apex method for searching organizations in Screen Flow
 */
public class CandidCharityFlowActions {
    
    /**
     * Input parameters for searching a single organization
     */
    public class SearchInput {
        @InvocableVariable(label='EIN' description='EIN to search for (e.g., 53-0242652)' required=true)
        public String ein;
    }
    
    /**
     * Output for single organization search - individual values ready for editing
     */
    public class SearchOutput {
        @InvocableVariable(label='Organization Name' description='Name of the organization')
        public String organizationName;
        
        @InvocableVariable(label='EIN' description='EIN of the organization')
        public String ein;
        
        @InvocableVariable(label='City' description='City of the organization')
        public String city;
        
        @InvocableVariable(label='State' description='State of the organization')
        public String state;
        
        @InvocableVariable(label='Address' description='Street address of the organization')
        public String address;
        
        @InvocableVariable(label='Zip Code' description='Zip code of the organization')
        public String zipCode;
        
        @InvocableVariable(label='Is Verified' description='Whether the organization is verified 501(c)(3)')
        public Boolean isVerified;
        
        @InvocableVariable(label='Success' description='Whether the search was successful')
        public Boolean success;
        
        @InvocableVariable(label='Error Message' description='Error message if the search failed')
        public String errorMessage;
    }
    
    /**
     * Search for a single organization by EIN
     */
    @InvocableMethod(label='Search Single Organization' description='Search for a single organization by EIN')
    public static List<SearchOutput> searchSingleOrganization(List<SearchInput> inputs) {
        List<SearchOutput> outputs = new List<SearchOutput>();
        
        for (SearchInput input : inputs) {
            SearchOutput output = new SearchOutput();
            
            try {
                // Validate EIN input
                if (String.isBlank(input.ein)) {
                    output.success = false;
                    output.errorMessage = 'EIN is required';
                    outputs.add(output);
                    continue;
                }
                
                // Call the charity check API
                CandidCharity cc = new CandidCharity();
                CandidCharity.CharityCheckData result = cc.charityCheck(input.ein, 'single');
                
                if (result != null) {
                    // Map API result to Flow output
                    output.organizationName = result.organization_name != null ? result.organization_name : '';
                    output.ein = result.ein != null ? result.ein : '';
                    output.city = result.city != null ? result.city : '';
                    output.state = result.state != null ? result.state : '';
                    output.address = buildShippingStreet(result.address_line1, result.address_line2);
                    output.zipCode = result.zip != null ? result.zip : '';
                    output.isVerified = result.isVerified();
                    output.success = true;
                } else {
                    // No organization found
                    output.success = false;
                    output.errorMessage = 'No organization found with EIN: ' + input.ein;
                }
                
            } catch (Exception e) {
                output.success = false;
                output.errorMessage = e.getMessage();
                System.debug('Single Search Error: ' + e.getMessage());
            }
            
            outputs.add(output);
        }
        
        return outputs;
    }
    
    /**
     * Helper method to build shipping street address from address lines
     */
    @TestVisible
    private static String buildShippingStreet(String addressLine1, String addressLine2) {
        if (String.isBlank(addressLine1)) {
            return String.isBlank(addressLine2) ? '' : addressLine2;
        }
        
        if (String.isBlank(addressLine2)) {
            return addressLine1;
        }
        
        return addressLine1 + ' ' + addressLine2;
    }
}
