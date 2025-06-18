/**
 ** Apex class that implements the Candid Charity Check API - https://developer.candid.org/reference/charitycheck_v1
 **
 **
 **/
global virtual with sharing class CandidCharity {
  
  protected CandidCharity_Settings__c settings = CandidCharity_Settings__c.getInstance();
  protected String baseEndpoint = 'https://api.candid.org/charitycheck';
  public String userId { protected get; set; }
  public String password { protected get; set; }
  // public String searchApiKey { protected get; set; }
  public String charityCheckApiKey { protected get; set; }
  // public String detailApiKey { protected get; set; }
  
  /**
   ** Constructors - you can provide the auth credentials or look them up from custom settings
   **/
  public CandidCharity(String uid, String pwd) {
    userId = uid;
    password = pwd;
  }
  public CandidCharity( String cchkKey ) {
    CandidCharityApiKey = cchkKey;
  }
  public CandidCharity() {
    userId = settings.API_User_Id__c;
    password = settings.API_Password__c;
    // searchApiKey = settings.Search_API_Key__c;
    charityCheckApiKey = settings.Charity_Check_API_Key__c;
    // detailApiKey = settings.Detail_API_Key__c;
  }
  
  
  global class charityCheckException extends Exception {
    public Integer statusCode { get; set; }
  }
  
  global class OrganizationType {
    public String organization_type;
    public String deductibility_limitation;
    public String deductibility_status_description;
  }
  
  /**
   ** Custom data types for response data
   **/  global class CharityCheckData {
    public String organization_id;
    public String organization_info_last_modified;
    public String ein;
    public String organization_name;
    public String organization_name_aka;
    public String address_line1;
    public String address_line2;
    public String city;
    public String state;
    public String state_name;
    public String zip;
    public String filing_req_code;
    public String charity_check_last_modified;
    public String pub78_church_message;
    public String pub78_organization_name;
    public String pub78_ein;
    public String pub78_verified;
    public String pub78_city;
    public String pub78_state;
    public String pub78_indicator;
    public List<OrganizationType> organization_types;
    public String most_recent_pub78;
    public String most_recent_irb;
    public String bmf_church_message;
    public String bmf_organization_name;
    public String bmf_ein;
    public String bmf_status;
    public String most_recent_bmf;
    public String bmf_subsection;
    public String subsection_description;
    public String foundation_code;
    public String foundation_code_description;
    public String ruling_month;
    public String ruling_year;
    public String adv_ruling_month;
    public String adv_ruling_year;
    public String group_exemption;
    public String exempt_status_code;
    public String ofac_status;
    public String revocation_code;
    public String revocation_date;
    public String reinstatement_date;
    public String irs_bmf_pub78_conflict;
    public String foundation_509a_status;
    public String irb_organization_id;
    public String bulletin_number;
    public String bulletin_url;
    public String effective_date;
    public String irb_last_modified;
    public String report_date;
    public String foundation_type_code;
    public String foundation_type_description;
    public List<Object> parent_organizations;
    public String retrieval_time_in_milliseconds;
    public String total_pipeline_time_in_milliseconds;
    public String responseJson;    // utility method to check if the org is 501c3 verified
    
    public Boolean isVerified() {
      return ( pub78_verified == 'True' && bmf_status == 'True' &&
        (ofac_status == null || ofac_status == '' || ofac_status.contains('was not included'))
        && subsection_description == '501(c)(3) Public Charity');
    }
  }
  
  
  global class CharityCheckBulkData {
    public List<CharityCheckData> data { get; set; }  // Matches JSON property name
    public String responseJson;
    
    public CharityCheckBulkData() {
      data = new List<CharityCheckData>();
    }
    
    // Helper method to get organizations (keeps your original naming intention)
    public List<CharityCheckData> getOrganizations() {
      return data != null ? data : new List<CharityCheckData>();
    }
    
    // Helper method to check if results exist
    public Boolean hasResults() {
      return data != null && !data.isEmpty();
    }
  }
  
  
  
  /**
   ** Main method for CharityCheck API - provide 9-digit API and get back all the verification data
   **/
  public CharityCheckData charityCheck( String ein, String charityCheckType ) {
    if (ein == null) {
      throw new charityCheckException('EIN cannot be null.');
    }
    
    String cleanedEin = cleanEin(ein);
    String endpoint = baseEndpoint;
    
    if(charityCheckType.toLowerCase() == 'single'){
      endpoint += '/v1/' + cleanedEin;
      String js = callSingleCheck( endpoint, charityCheckApiKey );
      
      if (js == null) {
        return null; // 404 case
      }
      
      try {
        // Parse the JSON response that has a "data" wrapper
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(js);
        Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
        
        CharityCheckData ccd = (CharityCheckData) JSON.deserialize(JSON.serialize(dataMap), CharityCheckData.class);
        ccd.responseJson = JSON.serializePretty(ccd);
        return ccd;
      }
      catch (Exception e) {
        charityCheckException cce = new charityCheckException('Error parsing JSON response from Candid Charity Check API: ' + e.getMessage());
        cce.statusCode = 500;
        throw cce;
      }
    }
    else if(charityCheckType.toLowerCase() == 'pdf'){
      endpoint += '/pdf/v2/pdf/' + cleanedEin;
      String base64Pdf = callPDFCheck( endpoint, charityCheckApiKey );
      
      if (base64Pdf == null) {
        return null; // 404 case
      }
      
      // For PDF, return a CharityCheckData with just the PDF content
      CharityCheckData ccd = new CharityCheckData();
      ccd.ein = cleanedEin;
      ccd.responseJson = base64Pdf; // Store base64 PDF in responseJson field
      return ccd;
    }
    else {
      List<String> validTypes = new List<String>{'single', 'pdf'};
      charityCheckException cce = new charityCheckException('Invalid charity check type. Valid types are: ' + String.join(validTypes, ', '));
      cce.statusCode = 400;
      throw cce;
    }
  }
  
  // Overloaded Method for Bulk Charity Check
  public CharityCheckBulkData charityCheck( String[] einList ) {
    if (einList == null || einList.isEmpty()) {
      throw new charityCheckException('EIN list cannot be null or empty.');
    }
    
    // Clean all EINs
    String[] cleanedEins = new String[]{};
    for (String ein : einList) {
      cleanedEins.add(cleanEin(ein));
    }
    
    String endpoint = baseEndpoint + '/bulk/v1';
    String js = callBulkCheck( endpoint, charityCheckApiKey, cleanedEins );
    
    if (js == null) {
      return null; // 404 case
    }
    try {
      CharityCheckBulkData ccd = (CharityCheckBulkData) JSON.deserialize(js, CharityCheckBulkData.class);
      ccd.responseJson = JSON.serializePretty(ccd);
      return ccd;
    }
    catch (Exception e) {
      charityCheckException cce = new charityCheckException('Error parsing JSON response from Candid Charity Check API: ' + e.getMessage());
      cce.statusCode = 500;
      throw cce;
    }
  }
  
  
  
  // /**
  //  ** Shared methods
  // **/
  protected String cleanEin(String ein) {
    if (ein == null) throw new charityCheckException('EIN cannot be null.');
    ein = ein.replace('-', '').replace(' ', '');
    if (ein.length() != 9) throw new charityCheckException('EIN must consist of 9 numbers (e.g. 94-3347800).');
    if (!ein.isNumeric()) throw new charityCheckException('EIN must be numeric (e.g. 94-3347800).');
    return (ein.left(2) + '-' + ein.right(7));
  }
  
  protected String callSingleCheck( String endpoint, String apiKey ) {
    
    // if an API key is provided, send that - otherwise username and password
    String authString = (apiKey != null) ? (apiKey + ':') : (userId + ':' + password);
    
    String authorizationHeader = 'Basic ' +
      String.valueOf(EncodingUtil.base64Encode(Blob.valueOf(authString)));
    
    HttpRequest http = new HttpRequest();
    http.setEndpoint(endpoint);
    http.setMethod('GET');
    http.setHeader('Authorization', authorizationHeader);
    // http.setHeader('Accept', 'application/json'); not needed for GET requests
    
    String response;
    Integer statusCode;
    Http con = new Http();
    HttpResponse hs = new HttpResponse();
    //system.debug(LoggingLevel.WARN, 'candid request >>>> \n' + String.valueOf(http) + '\n');
    hs = con.send(http);
    
    if (hs.getStatusCode() == 200) {
      //system.debug(LoggingLevel.WARN, 'candid response >>>> \n'+ hs.getBody() + '\n');
      return hs.getBody();
    } else if (hs.getStatusCode() == 404) {
      //system.debug(LoggingLevel.WARN, 'candid response >>>> \nError 404: There is an error in the URL string or the requested information is not available.\n');
      return null;
    } else {
      Integer status = hs.getStatusCode();
      String err = 'Rats! Candid returned status code ' + String.valueOf(status);
      if (status == 401)
        err += ': Unauthorized. The request requires user authentication.';
      else if (status == 403)
        err += ': Forbidden. The API understood the request, but is refusing to fulfill it. Most commonly, this means that the user has exceeded their request limit or does not have permissions to access this API.';
      else if (status == 500)
        err += ': Server Error. The API encountered an unexpected condition which prevented it from fulfilling the request.';
      else if (status == 503)
        err += ': Service Unavailable. The API is unavailable to handle the request due to a temporary overloading or maintenance of the server.';
      else
        err += '.';
      
      charityCheckException cce = new charityCheckException(err);
      cce.statusCode = status;
      throw cce;
    }
  }
  
  protected String callPDFCheck( String endpoint, String apiKey ) {
    
    // if an API key is provided, send that - otherwise username and password
    String authString = (apiKey != null) ? (apiKey + ':') : (userId + ':' + password);
    
    String authorizationHeader = 'Basic ' +
      String.valueOf(EncodingUtil.base64Encode(Blob.valueOf(authString)));
    
    HttpRequest http = new HttpRequest();
    http.setEndpoint(endpoint);
    http.setMethod('GET');
    http.setHeader('Authorization', authorizationHeader);
    http.setHeader('Accept', 'application/pdf'); // NEEDED for PDF requests
    
    Http con = new Http();
    HttpResponse hs = con.send(http);
    
    if (hs.getStatusCode() == 200) {
      // For PDF, you might want to return base64 encoded content or handle differently
      return EncodingUtil.base64Encode(hs.getBodyAsBlob());
    } else if (hs.getStatusCode() == 404) {
      return null;
    } else {
      Integer status = hs.getStatusCode();
      String err = 'Rats! Candid returned status code ' + String.valueOf(status);
      if (status == 401)
        err += ': Unauthorized. The request requires user authentication.';
      else if (status == 403)
        err += ': Forbidden. The API understood the request, but is refusing to fulfill it. Most commonly, this means that the user has exceeded their request limit or does not have permissions to access this API.';
      else if (status == 500)
        err += ': Server Error. The API encountered an unexpected condition which prevented it from fulfilling the request.';
      else if (status == 503)
        err += ': Service Unavailable. The API is unavailable to handle the request due to a temporary overloading or maintenance of the server.';
      else
        err += '.';
      
      charityCheckException cce = new charityCheckException(err);
      cce.statusCode = status;
      throw cce;
    }
  }
  
  protected String callBulkCheck( String endpoint, String apiKey, String[] einList ) {
    
    String jsonBody = JSON.stringify(einList);
    
    
    // if an API key is provided, send that - otherwise username and password
    String authString = (apiKey != null) ? (apiKey + ':') : (userId + ':' + password);
    
    String authorizationHeader = 'Basic ' +
      String.valueOf(EncodingUtil.base64Encode(Blob.valueOf(authString)));
    
    HttpRequest http = new HttpRequest();
    http.setEndpoint(endpoint);
    http.setMethod('POST');
    http.setHeader('Authorization', authorizationHeader);
    http.setHeader('Content-Type', 'application/json');
    http.setHeader('Accept', 'application/json');
    http.setBody(jsonBody);
    
    Integer statusCode;
    Http con = new Http();
    HttpResponse hs = con.send(http);;
    
    if (hs.getStatusCode() == 200) {
      return hs.getBody();
    } else if (hs.getStatusCode() == 404) {
      return null;
    } else {
      Integer status = hs.getStatusCode();
      String err = 'Rats! Candid returned status code ' + String.valueOf(status);
      if (status == 401)
        err += ': Unauthorized. The request requires user authentication.';
      else if (status == 403)
        err += ': Forbidden. The API understood the request, but is refusing to fulfill it. Most commonly, this means that the user has exceeded their request limit or does not have permissions to access this API.';
      else if (status == 500)
        err += ': Server Error. The API encountered an unexpected condition which prevented it from fulfilling the request.';
      else if (status == 503)
        err += ': Service Unavailable. The API is unavailable to handle the request due to a temporary overloading or maintenance of the server.';
      else
        err += '.';
      
      charityCheckException cce = new charityCheckException(err);
      cce.statusCode = status;
      throw cce;
    }
  }
}