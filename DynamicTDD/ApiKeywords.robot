*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           json
Library           DateTime
Library           db.py
Resource          Keywords.robot
Library	          Imageupload.py
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py

*** Variables ***

${API_BASE_URL}       http://${HOSTED_IP}/api/rest

*** Keywords ***

Enable Disable API gateway
    [Arguments]  ${status}  
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/account/settings/${status}/apiGateway   expected_status=any
    Check Deprication  ${resp}  Enable Disable API gateway
    RETURN  ${resp}


Get SP Token
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/account/settings/apiGateway  expected_status=any
    Check Deprication  ${resp}  Get SP Token
    RETURN  ${resp}


Check And Create ApiYNW Session
    ${res}=   Session Exists    apiynw
    IF  not ${res}
        Create Session    apiynw    ${API_BASE_URL}   headers=${headers}  verify=true
    END


Create User Token
    [Arguments]    ${usname}  ${passwrd}   ${sptoken}   ${countryCode}
    ${login}=    Create Dictionary    loginId=${usname}  password=${passwrd}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${sptoken}
    Check And Create ApiYNW Session
    ${resp}=    POST On Session    apiynw    provider/login    data=${log}  expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Create User Token
    RETURN  ${resp}


Get Leads Details
    [Arguments]    ${user_token}  
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/leads    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Leads Details
    RETURN  ${resp}


Get Leads Count
    [Arguments]    ${user_token}   
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/leads/count    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Leads Count
    RETURN  ${resp}


Get Customer Details
    [Arguments]    ${user_token}   
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/customers    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Customer Details
    RETURN  ${resp}


Get Customer Count
    [Arguments]    ${user_token}   
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/customers/count    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Customer Count
    RETURN  ${resp}


Get Leads Details With Filter
    [Arguments]    ${user_token}   &{kwargs}
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/lead  params=${kwargs}    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Leads Details With Filter
    RETURN  ${resp}


Get KYC Details 
    [Arguments]    ${user_token}   ${lead_uid}
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    lms/kyc/${lead_uid}    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get KYC Details 
    RETURN  ${resp}


Get Loan Applications 
    [Arguments]    ${user_token}  &{kwargs}
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    cdl/loanapplications   params=${kwargs}   expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Loan Applications 
    RETURN  ${resp}


Get Loan Applications Count
    [Arguments]    ${user_token}  &{kwargs}
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    cdl/loanapplications/count   params=${kwargs}  expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Loan Applications Count
    RETURN  ${resp}


Get Loan Applications By Uid
    [Arguments]    ${loan_uid}  ${user_token}  
    ${apiheaders}=     Create Dictionary    Content-Type=application/json    authorization=${user_token}
    Check And Create ApiYNW Session
    ${resp}=    GET On Session    apiynw    cdl/loanapplications/${loan_uid}    expected_status=any  headers=${apiheaders}
    Check Deprication  ${resp}  Get Loan Applications By Uid
    RETURN  ${resp}
