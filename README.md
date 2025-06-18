apex-guidestar
==============

Salesforce.com Apex integration with the [Candid's Charity Checker API](https://developer.candid.org/) - supports single, bulk or pdf charity check for [Candid's extensive database](http://www.candid.org/) of US nonprofit organizations.

Read all about the Candid API at [developer.candid.org](https://developer.candid.org/reference/welcome). 

Usage:

	// initialize the api class using Candid Charity Checker API key (CharityCheck API key)
    CandidCharity cdc = new CandidCharity('123abcdefg123');    

    // initialize the api class with Candid username and password
    CandidCharity cdc = new CandidCharity('somebody@example.com','password');    

    // initialize the api class using credentials stored in custom settings
    CandidCharity cdc = new CandidCharity();    

    // perform 501c3 charity check based on EIN
    CandidCharity.CharityCheckData ccd = cdc.charityCheck('94-3347800', 'single');
        
    // perform a 501c3 charity check pdf report based on EIN
    CandidCharity.CharityCheck cc = cdc.charityCheck('94-3347800', 'pdf');
        
    // perform a bulk 501c3 charity check based on an array of EIN
    CandidCharity.CharityCheck cc = cdc.charityCheck(['94-3347800', '32-5490273']);


The package includes a custom setting where you can store your API credentials. This way, you won't have to pass them in when you initialize the api class. For better security, use API keys rather than username and password.

You can install the package into a Salesforce instance using the following URL:
  [https://githubsfdeploy.herokuapp.com/?owner=SalesforceFoundation&repo=apex-guidestar](https://githubsfdeploy.herokuapp.com/?owner=SalesforceFoundation&repo=apex-guidestar)


Comments and contributions are welcome!
