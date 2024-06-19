*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${withsym}      *#147erd
${onlyspl}      !@#$%^&
${alph_digits}  D3r52A

*** Test Cases ***

JD-TC-Forget_LoginId-1

    [Documentation]    Forget login Id - with all Credentials

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}

    # ........ Provider 1 ..........

    ${ph}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1  max=9999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${id}  ${resp.json()['id']}

    Set Suite Variable  ${email_id}  ${firstname}${ph}.${test_mail}

    ${resp}=  Update Email    ${id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot LoginId  countryCode=${countryCodes[1]}  phoneNo=${ph}  email=${email_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph}    ${OtpPurpose['ResetLoginId']}
    Set Suite Variable   ${key2}
    ${resp}=    Forgot LoginId     otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_str}=  Convert To String  ${loginId}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_str}

JD-TC-Forget_LoginId-2

    [Documentation]    Forget login Id - after getting login id calling the same again

    ${resp}=    Forgot LoginId     otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings      ${resp.json()}  ${ENTER_VALID_OTP}

JD-TC-Forget_LoginId-3

    [Documentation]    Forget login Id - with email id

    ${resp}=    Forgot LoginId    email=${email_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${email_id}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${email_id}    ${OtpPurpose['ResetLoginId']}

    ${resp}=    Forgot LoginId     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_str}=  Convert To String  ${loginId}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_str}

JD-TC-Forget_LoginId-4

    [Documentation]    Forget login Id - with phone and countrycode

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${ph}    ${OtpPurpose['ResetLoginId']}

    ${resp}=    Forgot LoginId     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_str}=  Convert To String  ${loginId}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_str}

JD-TC-Forget_LoginId-UH1

    [Documentation]    Forget login Id - where country code is not provided

    ${resp}=    Forgot LoginId  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${COUNTRY_CODEREQUIRED}

JD-TC-Forget_LoginId-UH2

    [Documentation]    Forget login Id - with out phone 

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${EMAIL_OR_PHONE_REQ}

JD-TC-Forget_LoginId-UH3

    [Documentation]    Forget login Id - otp purpose is empty

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH4

    [Documentation]    Forget login Id - otp purpose is invalid

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH5

    [Documentation]    Forget login Id - login id is empty

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${empty}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH6

    [Documentation]    Forget login Id - login id is invalid

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${ph_inv}=  Evaluate  ${PUSERNAME}+5666784

    ${resp}=    Account Activation  ${ph_inv}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH7

    [Documentation]    Forget login Id - otp is invalid

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${otp}=     Random Int  min=11  max=99

    ${resp}=    Forgot LoginId     otp=${otp}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${ENTER_VALID_OTP}

JD-TC-Forget_LoginId-UH8

    [Documentation]    Forget login Id - phone number is invalid

    ${ph_inv}=  Evaluate  ${PUSERNAME}+57866784

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph_inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph_inv}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH9

    [Documentation]    Forget login Id - with invalid email id

    ${inv}=     Random Int  min=1  max=99 
    Set Suite Variable  ${email_inv}  ${firstname}${inv}.${test_mail}

    ${resp}=    Forgot LoginId    email=${email_inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${email_inv}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forget_LoginId-UH10

    [Documentation]    Forget login Id - phone number is invalid less than 10 digits

    ${ph_inv}=  Random Int  min=99  max=99999999

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph_inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph_inv}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}