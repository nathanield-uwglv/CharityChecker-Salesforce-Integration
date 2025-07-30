apex-CandidCharityChecker
==============

Salesforce.com Apex integration with the [Candid's Charity Checker API](https://developer.candid.org/) - supports single, bulk or pdf charity check for [Candid's extensive database](http://www.candid.org/) of US nonprofit organizations.

Read all about the Candid API at [developer.candid.org](https://developer.candid.org/reference/welcome). 

## Recent Updates (2025)

- **Modernized Authentication**: Removed deprecated username/password authentication in favor of API key-only authentication using `Subscription-Key` header
- **Enhanced Flow Integration**: Added two new Invocable Apex classes for seamless Salesforce Flow integration
- **Improved Error Handling**: Better exception handling and user-friendly error messages
- **Bulk Operations**: Enhanced bulk charity check functionality with improved data structures
- **Security**: Added `.env` file support for local API key management (excluded from version control)

## Core Functionality

### Basic API Usage

```apex
// Initialize the API class using Candid Charity Checker API key
CandidCharity cdc = new CandidCharity('your-api-key-here');    

// Initialize the API class using credentials stored in custom settings
CandidCharity cdc = new CandidCharity();    

// Perform 501c3 charity check based on EIN
CandidCharity.CharityCheckData ccd = cdc.charityCheck('94-3347800', 'single');
        
// Perform a 501c3 charity check PDF report based on EIN
CandidCharity.CharityCheckData cc = cdc.charityCheck('94-3347800', 'pdf');
        
// Perform a bulk 501c3 charity check based on an array of EINs
CandidCharity.CharityCheckBulkData cc = cdc.charityCheck(new List<String>{'94-3347800', '32-5490273'});
```

### Flow Integration

```apex
// Use in Screen Flows for organization search
CandidCharityFlowActions.searchSingleOrganization(inputs);

// Use in Record Flows for Account creation/update
CandidCharityDetailsAction.getCharityDetails(inputs);
```

## File Structure and Functionality

### Core Classes

#### `CandidCharity.cls` - Main API Integration Class
- **Purpose**: Core class that handles all API communication with Candid's Charity Checker API
- **Key Features**:
  - Single organization lookup by EIN
  - Bulk organization verification (multiple EINs)
  - PDF report generation
  - Built-in 501(c)(3) verification logic
  - Comprehensive error handling and validation
- **Authentication**: Uses API key with `Subscription-Key` header (modern Candid API standard)
- **Methods**:
  - `charityCheck(String ein, String type)` - Single/PDF lookup
  - `charityCheck(List<String> einList)` - Bulk lookup
  - `isVerified()` - Helper method to check 501(c)(3) status

#### `CandidCharityFlowActions.cls` - Screen Flow Integration
- **Purpose**: Invocable Apex class designed for Screen Flows where users need to search and select organizations
- **Use Case**: Organization lookup screens where users can search by EIN and review/edit results
- **Key Features**:
  - Simple EIN-based search
  - Returns individual field values for easy binding to Flow screen components
  - Comprehensive error handling for user-friendly messages
  - Address formatting for display
- **Output Fields**: Organization name, EIN, address, city, state, zip, verification status

#### `CandidCharityDetailsAction.cls` - Record Flow Integration  
- **Purpose**: Invocable Apex class optimized for automated Account record creation/updates
- **Use Case**: Background processes, record-triggered flows, and automated data enrichment
- **Key Features**:
  - Maps Candid API response directly to Salesforce Account fields
  - Handles address formatting for `ShippingStreet`, `ShippingCity`, etc.
  - Optimized for bulk operations and automation
  - Returns full JSON response for debugging and audit trails
- **Output Fields**: Account-ready fields plus success/error handling

### Test Classes

#### `CandidCharityTest.cls` - Core API Testing
- **Purpose**: Comprehensive test coverage for the main `CandidCharity` class
- **Coverage**: 
  - Single, bulk, and PDF charity checks
  - Error scenarios (404, 401, 403, 500)
  - EIN validation and formatting
  - Mock HTTP responses matching real API structure
  - Verification logic testing

#### `CandidCharityFlowActionsTest.cls` - Flow Integration Testing
- **Purpose**: Test coverage for Flow-specific functionality
- **Coverage**:
  - Successful organization searches
  - Error handling (blank EIN, not found, API errors)
  - Address formatting validation
  - Flow input/output parameter mapping

### Configuration

#### `CandidCharity_Settings__c.object` - Custom Settings
- **Purpose**: Secure storage for API credentials and configuration
- **Fields**:
  - `Charity_Check_API_Key__c` - Primary API key for Candid Charity Checker API
  - `API_User_Id__c` - Legacy field (deprecated)
  - `API_Password__c` - Legacy field (deprecated)
- **Security**: Hierarchy custom setting allows org-wide, profile, or user-specific configuration

## Setup Instructions

1. **Install the Package**: Deploy all classes and the custom object to your Salesforce org
2. **Configure API Key**: 
   - Navigate to Setup → Custom Settings → Candid Charity Settings
   - Click "Manage" and add your Candid API key to `Charity_Check_API_Key__c`
3. **Test the Integration**: Use the test classes to verify functionality
4. **Flow Integration**: Add the Invocable Actions to your Flows as needed

## API Key Management

The package supports API key-only authentication (recommended) through:
- Custom Settings (for production/shared environments)
- Direct instantiation (for programmatic use)
- Local `.env` file (for development)

For better security, always use API keys rather than username and password authentication.

## Dependencies

- Salesforce Org with API access
- Valid Candid Charity Checker API subscription
- Remote Site Settings configured for `https://api.candid.org`

## Credits

Originally based on [SalesforceFoundation](https://github.com/SalesforceFoundation)'s [Apex-Guidestar](https://github.com/SalesforceFoundation/apex-guidestar) and modernized for the current Candid API infrastructure.
