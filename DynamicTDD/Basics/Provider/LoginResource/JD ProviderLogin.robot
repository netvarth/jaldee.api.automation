*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags      Encrypted Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${withsym}      *#147erd
${onlyspl}      !@#$%^&
${alph_digits}  D3r52A

*** Test Cases ***

JD-TC-Provider_Login-1

    [Documentation]  Encrypted Provider Login - with valid details

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
    ${ph}=  Evaluate  ${PUSERNAME}+5666400
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${highest_package}=  get_highest_license_pkg
    Set Suite Variable      ${highest_package}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId}
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-UH1

    [Documentation]  Encrypted Provider Login - where session alrady exists

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-UH2

    [Documentation]  Encrypted Provider Login - where login id is empty

    ${resp}=  Encrypted Provider Login  ${empty}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}         ${ENTER_LOGIN_ID}

JD-TC-Provider_Login-UH3

    [Documentation]  Encrypted Provider Login - not signed up

    ${ph2}=  Evaluate  ${PUSERNAME}+566457

    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${NOT_REGISTERED_CUSTOMER}

JD-TC-Provider_Login-UH4

    [Documentation]  Encrypted Provider Login - where password is empty

    ${resp}=  Encrypted Provider Login  ${loginId}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${PASSWORD_EMPTY}

JD-TC-Provider_Login-2

    [Documentation]    Provider User Login - user trying to login before reseting password

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #..... User Creation ......

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id}   ${resp.json()['id']}
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    # ${resp}=  View Waitlist Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Toggle Department Enable
    #     Log  ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END

    # ${resp}=  Get Departments
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}' 
    #     ${dep_name1}=  FakerLibrary.bs
    #     ${dep_code1}=   Random Int  min=100   max=999
    #     ${dep_desc1}=   FakerLibrary.word  
    #     ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Suite Variable  ${dep_id}  ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    # END

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id              ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${user1_id}       ${resp.json()['id']}
    Set Suite Variable  ${user_num}    ${resp.json()['mobileNo']}

    ${loginId_n}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId_n}

    ${resp}=    Reset LoginId  ${user1_id}  ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}         ${LOGIN_INVALID_USERID_PASSWORD}

JD-TC-Provider_Login-3

    [Documentation]    Provider User Login

    ${Password_n}=    Random Int  min=11111111  max=99999999

    ${resp}=    Forgot Password   loginId=${loginId_n}  password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${user_num}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-4

    [Documentation]    Existing provider login 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-Provider_Login-5

    [Documentation]    ProviderConsumer  Login with token After Sign up

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME70}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${empty}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-6

    [Documentation]    creating two user with same mobile number in same account

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #..........  User 1 ..........

    ${user1}=  Evaluate  ${PUSERNAME}+5687965

    ${firstname_u}=  FakerLibrary.name
    ${lastname_u}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # FOR    ${i}    IN RANGE    3
    # ${pin}=  get_pincode
    # ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    # IF    '${kwstatus}' == 'FAIL'
    #         Continue For Loop
    # ELSE IF    '${kwstatus}' == 'PASS'
    #         Exit For Loop
    # END
    # END
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    # Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    # Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${resp}=  Create User  ${firstname_u}  ${lastname_u}   ${countryCodes[0]}  ${user1}   ${userType[0]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    #..........  User 2 ..........

    ${firstname_u2}=  FakerLibrary.name
    ${lastname_u2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date   

    ${resp}=  Create User  ${firstname_u2}  ${lastname_u2}  ${countryCodes[0]}  ${user1}  ${userType[0]}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${MOBILE_NO_USED}


JD-TC-Provider_Login-7

    [Documentation]    creating two user with same email in same account

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #..........  User 1 ..........

    ${user1}=  Evaluate  ${PUSERNAME}+5687784

    ${firstname_u}=  FakerLibrary.name
    ${lastname_u}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # FOR    ${i}    IN RANGE    3
    # ${pin}=  get_pincode
    # ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    # IF    '${kwstatus}' == 'FAIL'
    #         Continue For Loop
    # ELSE IF    '${kwstatus}' == 'PASS'
    #         Exit For Loop
    # END
    # END
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    # Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    # Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${resp}=  Create User  ${firstname_u}  ${lastname_u}   ${countryCodes[0]}  ${user1}   ${userType[0]}  email=${lastname_u}${user1}.${test_mail}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200

    #..........  User 2 ..........

    ${user2}=  Evaluate  ${PUSERNAME}+568845

    ${firstname_u2}=  FakerLibrary.name
    ${lastname_u2}=  FakerLibrary.last_name
    # ${dob2}=  FakerLibrary.Date   

    ${resp}=  Create User  ${firstname_u2}  ${lastname_u2}  ${countryCodes[0]}  ${user2}  ${userType[0]}  email=${lastname_u}${user1}.${test_mail}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${EMAIL_EXISTS}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Provider_Login-8

    [Documentation]    login id is less than 4 digit

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


JD-TC-Provider_Login-9

    [Documentation]    login id is greater than 40 digit

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${cookie_parts}    ${jsessionynw_value}    Split String    ${resp.request.headers['Cookie']}    =
    Log   ${jsessionynw_value}

    ${resp}=    Account Activation  ${ph}  ${OtpPurpose['ProviderSignUp']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${random_number}=    Random Number 	       digits=41
    
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${random_number}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}          ${LOGIN_ID_LIMIT}

JD-TC-Provider_Login-10

    [Documentation]    SA Login

    ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200