*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        ConsumerLogin
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${self}     0

*** Test Cases ***

JD-TC-Update consumer number-3

    [Documentation]     Update a consumer's phone number with different country code and then update it back to old country code

    
    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERNAME_0}=  Set Variable  ${PO_Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Consumer Profile With Emailid    ${firstname}  ${lastname}  ${EMPTY}   ${dob}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  ${OtpPurpose['ConsumerVerifyEmail']}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}   

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  ${OtpPurpose['ConsumerVerifyEmail']}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"