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

    ${ph}=  Evaluate  ${PUSERNAME}+5678001
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202
    Log    Request Headers: ${resp.request.headers}
    Log    Request Cookies: ${resp.request.headers['Cookie']}
    ${cookie_parts}    ${jsessionynw_value}    Split String    ${resp.request.headers['Cookie']}    =
    Log   ${jsessionynw_value}


    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}     JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId}


    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${id}  ${resp.json()['id']}
    Set Suite Variable      ${userName}  ${resp.json()['userName']}

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
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}        ${userName}
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
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${PHONE_NOT_REGISTERED}

JD-TC-Forget_LoginId-UH9

    [Documentation]    Forget login Id - with invalid email id

    ${inv}=     Random Int  min=1  max=99 
    Set Suite Variable  ${email_inv}  ${firstname}${inv}.${test_mail}

    ${resp}=    Forgot LoginId    email=${email_inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${EMAIL_NOT_REGISTERED}

JD-TC-Forget_LoginId-UH10

    [Documentation]    Forget login Id - phone number is invalid less than 10 digits

    ${ph_inv}=  Random Int  min=99  max=99999999

    ${resp}=    Forgot LoginId    countryCode=${countryCodes[1]}  phoneNo=${ph_inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}      ${PHONE_NOT_REGISTERED}

JD-TC-Forget_LoginId-5

    [Documentation]    Forget login Id - creating a sample user, reset login id for that user after that calling forgot login id

    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #..... User Creation ......

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id}   ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id              ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${user1_id}       ${resp.json()['id']}
    Set Suite Variable  ${user_num}    ${resp.json()['mobileNo']}

    ${loginId_n}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId_n}

    ${resp}=    Reset LoginId  ${user1_id}  ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot LoginId  countryCode=${countryCodes[1]}  phoneNo=${user_num}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${user_num}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key3} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['ResetLoginId']}
    ${resp}=    Forgot LoginId     otp=${key3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_usr}=  Convert To String  ${loginId_n}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_usr}

    ${Password_n}=    Random Int  min=11111111  max=99999999

    ${resp}=    Forgot Password   loginId=${loginId_n}  password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${user_num}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key4} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key4}

    ${resp}=    Forgot Password     otp=${key4}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId_n}  ${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Forget_LoginId-6

    [Documentation]    Forget login Id - where number is 555 number

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname3}
    Set Suite Variable      ${lastname3}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname3}  ${lastname3}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId555}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId555}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId555}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${loginId555}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot LoginId  countryCode=${countryCodes[1]}  phoneNo=${phone}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key555} =   db.Verify Accnt   ${phone}    ${OtpPurpose['ResetLoginId']}
    Set Suite Variable   ${key555}

    ${resp}=    Forgot LoginId     otp=${key555}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_555}=  Convert To String  ${loginId555}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_555}

JD-TC-Forget_LoginId-7

    [Documentation]    Forget login Id - using Existing provider and login after forgot login id

    ${resp}=    Forgot LoginId  countryCode=${countryCodes[1]}  phoneNo=${PUSERNAME100}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME100}  ${OtpPurpose['ResetLoginId']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${keyog} =   db.Verify Accnt   ${PUSERNAME100}    ${OtpPurpose['ResetLoginId']}
    Set Suite Variable   ${keyog}
    ${resp}=    Forgot LoginId     otp=${keyog}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${loginId_str}=  Convert To String  ${PUSERNAME100}
    Dictionary Should Contain Key    ${resp.json()}      ${loginId_str}

    ${resp}=  Provider Login  ${loginId_str}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    