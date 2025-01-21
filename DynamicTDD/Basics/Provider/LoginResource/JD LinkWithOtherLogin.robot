*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags      Encrypted Provider Login
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
      
${withsym}      *#147erd
${onlyspl}      !@#$%^&
${alph_digits}  D3r52A

*** Test Cases ***

JD-TC-Link_With_Other_Login-1

    [Documentation]    Link With other login

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

    ${ph}=  Evaluate  ${PUSERNAME}+5666514
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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
    Set Suite Variable   ${jsessionynw_value}

    ${loginId}=     Random Int  min=111111  max=999999
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
    Set Suite Variable      ${username}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id}   ${resp.json()['id']}
    Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${number}

    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${name3}=  FakerLibrary.word
    ${emails1}=  Emails  ${name3}  Email  ${number}${P_Email}.${test_mail}  ${views}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${b_loc}=  Create Dictionary  place=${city}   longitude=${longi}   lattitude=${latti}    googleMapUrl=${url}   pinCode=${postcode}  address=${address}
    ${emails}=  Create List  ${emails1}
    ${resp}=  Update Business Profile with kwargs   businessName=${bs}   shortName=${bs}   businessDesc=Description   baseLocation=${b_loc}   emails=${emails}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ........ Provider 2 ..........

    ${ph2}=  Evaluate  ${PUSERNAME}+5647895
    Set Suite Variable  ${ph2}
    ${firstname2}=  generate_firstname
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname2}
    Set Suite Variable      ${lastname2}

    ${resp}=  Account SignUp  ${firstname2}  ${lastname2}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph2}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph2}  ${OtpPurpose['ProviderSignUp']} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId2}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId2}
    
    ${resp}=  Account Set Credential  ${ph2}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${username2}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id2}   ${resp.json()['id']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId2}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph2}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph2}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId2}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Link_With_Other_Login-2

    [Documentation]    Link With other login - Provider 1 Get list of all connections

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-3

    [Documentation]    Link With other login - Provider 2 Get list of all connections

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}     ${username}
    Should Be Equal As Strings    ${resp.json()['${loginId}']['accountId']}    ${acc_id}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-4

    [Documentation]    Link With other login - sign up provider 3 , provider 2 link provider 3 and get list of limks

    # ........ Provider 3 ..........

    ${ph3}=  Evaluate  ${PUSERNAME}+8745862
    Set Suite Variable  ${ph3}
    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname}
    Set Suite Variable      ${lastname}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${ph3}   1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${ph3}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId3}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId3}
    
    ${resp}=  Account Set Credential  ${ph3}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${username3}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id3}   ${resp.json()['id']}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId3}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph3}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph3}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId3}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}     ${username}
    Should Be Equal As Strings    ${resp.json()['${loginId}']['accountId']}    ${acc_id}
    Should Be Equal As Strings    ${resp.json()['${loginId3}']['userName']}     ${username3}
    Should Be Equal As Strings    ${resp.json()['${loginId3}']['accountId']}    ${acc_id3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-5

    [Documentation]    Link With other login - Provider 3 Get list of all connections

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-6

    [Documentation]    Link With other login - Provider 1 Get list of all connections

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH1

    [Documentation]    Link With other login - without login

    ${resp}=    Connect with other login  ${loginId3}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Link_With_Other_Login-UH2

    [Documentation]    Link With other login - Provider 1 linking the same provider again

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId2}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${ALREADY_LINKED}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-Link_With_Other_Login-7

    [Documentation]    Link With other login - provider 1 create a user and linking that user with provider 1 and getting linked listes from provider 1 and user      

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     #..... User Creation ......

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id}   ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    # ${resp}=  Get Waitlist Settings
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Enable Disable Department  ${toggle[0]}
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
    Should Be Equal As Strings              ${resp.status_code}  200
    Set Suite Variable  ${user1_id}         ${resp.json()['id']}
    Set Suite Variable  ${user_num}         ${resp.json()['mobileNo']}
    Set Suite Variable  ${user_firstName}   ${resp.json()['firstName']}
    Set Suite Variable  ${user_lastName}    ${resp.json()['lastName']}
    
    ${loginId_n}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId_n}

    ${resp}=    Reset LoginId  ${user1_id}  ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Password_n}=    Random Int  min=11111111  max=99999999
    Set Suite Variable      ${Password_n}

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

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${loginId_n}    password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${user_num}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId_n}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}
    Should Be Equal As Strings    ${resp.json()['${loginId_n}']['userName']}    ${user_firstName} ${user_lastName} 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}     ${username}
    Should Be Equal As Strings    ${resp.json()['${loginId}']['accountId']}    ${acc_id}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-8

    [Documentation]    Link With other login - provider 2 link with provider 1 created user and get linked list from both sides

    ${resp}=  Encrypted Provider Login  ${loginId2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Connect with other login  ${loginId_n}    password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${user_num}  ${OtpPurpose['LinkLogin']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['LinkLogin']}  ${jsessionynw_value}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId_n}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId_n}']['userName']}    ${user_firstName} ${user_lastName} 
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}     ${username}
    Should Be Equal As Strings    ${resp.json()['${loginId}']['accountId']}    ${acc_id}
    Should Be Equal As Strings    ${resp.json()['${loginId3}']['userName']}     ${username3}
    Should Be Equal As Strings    ${resp.json()['${loginId3}']['accountId']}    ${acc_id3}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId}']['userName']}     ${username}
    Should Be Equal As Strings    ${resp.json()['${loginId}']['accountId']}    ${acc_id}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH3

    [Documentation]    Link With other login - linking self

    #... clear this logiut when above case is passed

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ... need to be 422 error message giving 4222 to know this change

    ${resp}=    Connect with other login  ${loginId}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   202

    ${resp}=    Account Activation      ${ph}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${CANT_LINK_YOURSELF}

    ${resp}=    List all links of a loginId
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['userName']}     ${username2}
    Should Be Equal As Strings    ${resp.json()['${loginId2}']['accountId']}    ${acc_id2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH4

    [Documentation]    Link With other login - where login id is invalid

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=100000  max=200000

    ${resp}=    Connect with other login  ${inv}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    	Invalid Login Id

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH5

    [Documentation]    Link With other login - where password is invalid

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${inv}=     Random Int  min=100000  max=200000

    ${resp}=    Connect with other login  ${loginId}    password=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${ph}  ${OtpPurpose['LinkLogin']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${ph}    ${OtpPurpose['LinkLogin']}   ${jsessionynw_value}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INCORRECT_PASSWORD}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH6

    [Documentation]    Link With other login - where provider is Deactivated 

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone}=  Evaluate  ${PUSERNAME}+5741548
    Set Suite Variable  ${phone}
    ${firstname_u1}=  generate_firstname
    ${lastname_u1}=  FakerLibrary.last_name
    Set Suite Variable      ${firstname_u1}
    Set Suite Variable      ${lastname_u1}

    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp  ${firstname_u1}  ${lastname_u1}  ${None}  ${domain_list[0]}  ${subdomain_list[0]}  ${phone}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${phone}  ${OtpPurpose['ProviderSignUp']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId_u1}=     Random Int  min=111111  max=999999
    Set Suite Variable      ${loginId_u1}
    
    ${resp}=  Account Set Credential  ${phone}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId_u1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${loginId_u1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId_u1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ACCOUNT_DEACTIVATED_BASE}

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId_u1}    password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${INACTIVE_ACCOUNT}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH7

    [Documentation]    Link With other login - link with superadmin

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${SUSERNAME}    password=${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${SUSERNAME}  ${OtpPurpose['LinkLogin']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${SUSERNAME}    ${OtpPurpose['LinkLogin']}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${SUSERNAME}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CANT_LINK_SA}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Link_With_Other_Login-UH8

    [Documentation]    Link With other login - Deactivate user then link and switch 

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${user1_id}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${user1_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${user1_id}   status=${status[1]}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId_n}  ${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_DEACTIVATED}

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Connect with other login  ${loginId_n}  password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${USER_DISABLED}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${user1_id}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${user1_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${user1_id}   status=${status[0]}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Connect with other login  ${loginId_n}  password=${Password_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation      ${user_num}  ${OtpPurpose['LinkLogin']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key2} =   db.Verify Accnt   ${user_num}    ${OtpPurpose['LinkLogin']}  ${jsessionynw_value}
    Set Suite Variable   ${key2}

    ${resp}=    Connect with other login  ${loginId_n}   otp=${key2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  EnableDisable User  ${user1_id}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${user1_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${user1_id}   status=${status[1]}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Switch login    ${loginId_n}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${USER_DISABLED}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200