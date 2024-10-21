*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags      Encrypted Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${validpasswithsym}    ABCD1234@
${lesspass}     ABCD123
${validpass}    ABCD1234
${validpass2}    EFGH1234

*** Test Cases ***

JD-TC-Forgot_Password-1

    [Documentation]    Forgot Password - with all Credentials

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

    ${ph}=  Evaluate  ${PUSERNAME}+5665472
    Set Suite Variable  ${ph}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${id}  ${decrypted_data['id']}
    Set Suite Variable      ${userName}  ${decrypted_data['userName']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${ph}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId}  ${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Forgot_Password-2

    [Documentation]    Forgot Password - where login id is empty

    ${resp}=    Forgot Password   loginId=${empty}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${LOGIN_ID_REQ}

JD-TC-Forgot_Password-3

    [Documentation]    Forgot Password - where Password is empty

    ${resp}=    Forgot Password   loginId=${loginId}  password=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

JD-TC-Forgot_Password-UH1

    [Documentation]    Forgot Password - verify otp using invalid mobile

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${inv}=     Random Int  min=999  max=99999

    ${resp}=    Account Activation  ${inv}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forgot_Password-UH2

    [Documentation]    Forgot Password - verify otp using empty mobile

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${empty}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forgot_Password-UH3

    [Documentation]    Forgot Password - otp purpose is wrong

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${loginId}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${OTP_VALIDATION_FAILED}

JD-TC-Forgot_Password-UH4

    [Documentation]    Forgot Password - otp is invalid

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${otp}=      Random Int  min=999  max=99999

    ${resp}=    Forgot Password     otp=${otp}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${ENTER_VALID_OTP}

JD-TC-Forgot_Password-UH5

    [Documentation]    Forgot Password - after setting new password try to login with old password 

    ${resp}=  Encrypted Provider Login  ${loginId}  ${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${loginId}  password=${validpass2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${ph}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings      ${resp.json()}      ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-Forgot_Password-5

    [Documentation]    Forgot Password - existing provider reset password and login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Forgot Password   loginId=${PUSERNAME100}  password=${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME100}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key_ep} =   db.Verify Accnt   ${PUSERNAME100}    ${OtpPurpose['ProviderResetPassword']}

    ${resp}=    Forgot Password     otp=${key_ep}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #.... Login using new password

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${validpass}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # .... Set Password to the old password

    ${resp}=    Forgot Password   loginId=${PUSERNAME100}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME100}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key_old} =   db.Verify Accnt   ${PUSERNAME100}    ${OtpPurpose['ProviderResetPassword']}

    ${resp}=    Forgot Password     otp=${key_old}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
