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
${wrongaccid}=    11

*** Test Cases ***

JD-TC-SendOtp-1
    [Documentation]    Send OTP with valid login id and account id

    ${resp}=   ProviderLogin  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME72}

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}


    ${resp}=  AddCustomer  ${NewCustomer}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${NewCustomer}

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendOtp-UH1
    [Documentation]    Send OTP with Another login id

    ${resp}=   ProviderLogin  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME72}

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendOtp-UH2
    [Documentation]    Send OTP where loginid is empty

    ${resp}=   ProviderLogin  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME72}

    ${resp}=    Send Otp For Login    ${empty}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendOtp-UH3
    [Documentation]    Send OTP with wrong accid
    ${resp}=   ProviderLogin  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME72}

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${wrongaccid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    