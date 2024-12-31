*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        Provider Signup
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
${onlyspl}      !@#$%^&.-
${alph_digits}  D3r52A
${withus}       Abc_1234
${withat}       ABC@12
${withdot}      ABC.12
${withatanuc}  ABC_@12
${ucafterat}   ABC@_d
${validpasswithsym}    ABCD1234@
${lesspass}     ABCD123
${validpass}    ABCD1234
${case1}        Abcdefg
${case2}        abcdefg

*** Test Cases ***

JD-TC-Provider_Signup-1

    [Documentation]    Complete Provider Signup ( Login id is number )

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
    ${ph}=  Evaluate  ${PUSERNAME}+5666554
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${highest_package}=  get_highest_license_pkg
    Set Suite Variable      ${highest_package}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Provider_Signup-2

    [Documentation]    Complete Provider Signup ( Loginid is email )

    ${ph2}=  Evaluate  ${PUSERNAME}+5666555
    Set Suite Variable  ${ph2}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph2}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph2}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${ph2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-3

    [Documentation]    Complete Provider Signup ( Loginid is name )

    ${ph3}=  Evaluate  ${PUSERNAME}+5666556
    Set Suite Variable  ${ph3}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph3}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph3}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}     FakerLibrary.firstName
    
    ${resp}=  Account Set Credential  ${ph3}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-4

    [Documentation]    Complete Provider Signup ( Loginid starting with special Char )

    ${ph4}=  Evaluate  ${PUSERNAME}+5666557
    Set Suite Variable  ${ph4}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph4}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph4}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph4}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${withsym}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${LOGIN_LOGINiD_VALIDATION_NOT_FOUND}

JD-TC-Provider_Signup-5

    [Documentation]    Complete Provider Signup ( Loginid only with special char )

    ${ph5}=  Evaluate  ${PUSERNAME}+56664400
    Set Suite Variable  ${ph5}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph5}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph5}  ${OtpPurpose['ProviderSignUp']}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph5}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${onlyspl}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}       422
    Should Be Equal As Strings      ${resp.json()}          ${LOGIN_LOGINiD_VALIDATION_NOT_FOUND}
*** Comments ***
JD-TC-Provider_Signup-6

    [Documentation]    Complete Provider Signup ( Loginid with alphabets and numbers )

    ${PO_Number}=  random_phone_num_generator  subscriber_number_length=10  cc=2
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number[0]}
    ${ph6}=  Set Variable  ${PO_Number[1]}
    Set Suite Variable  ${ph6}
    Set Suite Variable  ${country_code}

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph6}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph6}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph6}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${alph_digits}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${alph_digits}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-7

    [Documentation]    Provider Sign Up with same number ( Its Possible )

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId_sm}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId_sm}

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_sm}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId_sm}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-8

    [Documentation]    Provider Sign Up with same login id which already exists

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_sm}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${LOGINID_EXISTS}

JD-TC-Provider_Signup-UH1

    [Documentation]    Provider Sign Up with same number different country code and email id not provided

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph6}   1  countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${EMAIL_ID_REQUIRED}

JD-TC-Provider_Signup-9

    [Documentation]    Provider Sign Up with same number different country code and different login id

    Set Test Variable   ${email}     ${P_Email}${firstname}.${test_mail}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph6}   1  countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${email}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId_z}=     Random Int  min=9999  max=99999
    Set Suite Variable      ${loginId_z}

    ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_z}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId_z}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-10

    [Documentation]    Provider Sign Up with same number same country code and same login id ( international )

    Set Test Variable   ${email}     ${P_Email}${firstname}.${test_mail}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph6}   1  countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${email}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_z}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${LOGINID_EXISTS}

JD-TC-Provider_Signup-UH2

    [Documentation]  Provider sign up where firstname is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666578
    Set Suite Variable  ${phone}
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${empty}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${ENTER_FIRST_NAME}

JD-TC-Provider_Signup-UH3

    [Documentation]  Provider sign up where last name is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666579
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name

    ${resp}=  Account SignUp  ${firstname2}  ${empty}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${VALID_LAST_NAME}

JD-TC-Provider_Signup-UH4

    [Documentation]  Provider sign up where domain name is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666580
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${empty}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${INVALID_SUB_SECTOR}

JD-TC-Provider_Signup-UH5

    [Documentation]  Provider sign up where subdomain is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666581
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${empty}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${INVALID_SUB_SECTOR}

JD-TC-Provider_Signup-UH6

    [Documentation]  Provider sign up where phone is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666582
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${empty}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${PRIMARY_PHONENO_REQUIRED}

JD-TC-Provider_Signup-11

    [Documentation]  Provider sign up where licence pkg id is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666583
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()}         ${INVALID_PACKAGE_ID}

JD-TC-Provider_Signup-UH7

    [Documentation]  Provider sign up where account activation id is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666584
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${empty}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${OTP validation failed}

JD-TC-Provider_Signup-UH8

    [Documentation]  Provider sign up where otp purpose is wrong

    ${phone}=  Evaluate  ${PUSERNAME}+5666587
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ConsumerSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${OTP validation failed}

JD-TC-Provider_Signup-12

    [Documentation]  Provider sign up where otp purpose is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666523
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-UH9

    [Documentation]  Provider sign up activate phone is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666524
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${empty}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${OTP_DIGIT_VALID}

JD-TC-Provider_Signup-14

    [Documentation]  Provider sign up activate password is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666525
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${phone}  ${empty}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-Provider_Signup-15

    [Documentation]  Provider sign up activate otp purpose is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666526
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${empty}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-16

    [Documentation]  Provider sign up activate loginid is empty

    ${phone}=  Evaluate  ${PUSERNAME}+5666527
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-UH10

    [Documentation]  Provider sign up activate otp purpose is invalid

    ${phone}=  Evaluate  ${PUSERNAME}+5666528
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${OTP_DIGIT_VALID}

JD-TC-Provider_Signup-UH11

    [Documentation]  Provider sign up activate phone is invalid

    ${phone}=  Evaluate  ${PUSERNAME}+5666529
    Set Suite Variable  ${phone}
    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable   ${loginId}     ${P_Email}${firstname2}.${test_mail}

    ${phone2}=  Evaluate  ${PUSERNAME}+5666524
    
    ${resp}=  Account Set Credential  ${phone2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${OTP_DIGIT_VALID}

JD-TC-Provider_Signup-UH12

    [Documentation]  Provider sign up where phone number is invalid

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name

    ${phn}=     Random Int  min=111111  max=999999999

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${INVALID_PHONE_NUM}

JD-TC-Provider_Signup-17

    [Documentation]  Provider sign up using 555 number

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${P_Phone}  555${PH_Number}

    ${firstname_p}=  FakerLibrary.first_name
    ${lastname_p}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname_p}
    Set Suite Variable      ${lastname_p}

    ${resp}=  Account SignUp  ${firstname_p}  ${lastname_p}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${P_Phone}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${P_Phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    
    ${resp}=  Account Set Credential  ${P_Phone}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph}${\n}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-18

    [Documentation]  Provider sign up - where login id is having _

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${withus}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${withus}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-UH13

    [Documentation]    Provider Signup -login id is les than 4 digit

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId_Phn}=     Random Int  min=111  max=999
    
    ${resp}=  Account Set Credential  ${phn}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_Phn}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}          ${LOGIN_ID_LIMIT}


JD-TC-Provider_Signup-UH14

    [Documentation]    Provider Signup - login id is grater than 40 digit

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${random_number}=    Random Number 	       digits=41
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${random_number}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}          ${LOGIN_ID_LIMIT}

JD-TC-Provider_Signup-19

    [Documentation]  Provider sign up - with @

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${withat}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${withat}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-20

    [Documentation]  Provider sign up - with dot

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${withdot}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${withdot}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-21

    [Documentation]  Provider sign up - with @ and _

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${withatanuc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${withatanuc}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-UH15

    [Documentation]  Provider sign up - _ after @

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${ucafterat}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings      ${resp.json()}          ${LOGIN_LOGINiD_VALIDATION_NOT_FOUND}


JD-TC-Provider_Signup-UH16

    [Documentation]    Provider Signup -password is only number ( Password validation not added )

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    ${pass}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${pass}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}          ${LOGIN_PASSWORD_VALIDATION_NOT_FOUND}

JD-TC-Provider_Signup-UH17

    [Documentation]    Provider Signup -password is less than 8 digit ( Password validation not added )

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${lesspass}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}          ${LOGIN_PASSWORD_VALIDATION_NOT_FOUND}


JD-TC-Provider_Signup-UH18

    [Documentation]    Provider Signup -password contain only symbols ( Password validation not added )

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${onlyspl}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}          ${LOGIN_PASSWORD_VALIDATION_NOT_FOUND}


JD-TC-Provider_Signup-UH19

    [Documentation]    Provider Signup -password contain with _ ( Password validation not added )

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${withus}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}          ${LOGIN_PASSWORD_VALIDATION_NOT_FOUND}


JD-TC-Provider_Signup-22

    [Documentation]    Provider Signup -password is valid

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${validpasswithsym}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-23

    [Documentation]    Provider Signup -password is valid

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn}=  Evaluate  ${PUSERNAME}+785482
    Set Suite Variable  ${phn}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lg}=     Random Int  min=111111  max=999999
    
    ${resp}=  Account Set Credential  ${phn}  ${validpass}  ${OtpPurpose['ProviderSignUp']}  ${lg}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Signup-UH20

    [Documentation]    Provider Signup - Case Sensitive check 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phn2}=  Evaluate  ${PUSERNAME}+785482

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn2}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn2}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${phn2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${case1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... Sign up 2  ...........

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phn2}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phn2}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Set Credential  ${phn2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${case2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${LOGINID_EXISTS}