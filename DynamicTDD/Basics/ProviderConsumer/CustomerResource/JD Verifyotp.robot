*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

*** Test Cases ***

JD-TC-SendOtp-1


    [Documentation]    Verify OTP
    ${resp}=   Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${accountId}=    get_acc_id       ${PUSERNAME72}
    Set Suite Variable    ${accountId}

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}


    ${resp}=  AddCustomer  ${NewCustomer}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${NewCustomer}

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendOtp-UH1
 
    [Documentation]    Verify OTP where customer is not registered under provider
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NewCustomer1}    Generate random string    10    123456789
    ${NewCustomer1}    Convert To Integer  ${NewCustomer1}

    ${resp}=    Verify Otp For Login   ${NewCustomer1}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-SendOtp-UH2

    [Documentation]    Verify OTP with wrong purpose
 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   10
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-SendOtp-UH3

    [Documentation]    Verify OTP where loginid is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${empty}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}      ${OTP_VALIDATION_FAILED}
    