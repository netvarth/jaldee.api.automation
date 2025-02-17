***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading
${SERVICE9}  Threading12
${SERVICE10}  Threading13

***Test Cases***

JD-TC-ServiceCreationByUserLogin-1

     [Documentation]  Create a sample user

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+998812
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User      deptId=${dep_id}
    Set Suite Variable   ${PUSERNAME_U1}
    Set Suite Variable   ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ServiceCreationByUserLogin-2   

    [Documentation]  Create  a service for a valid user 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=20  max=50
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}

    ${resp}=  Create Service   ${SERVICE1}  ${description}   ${dur}    ${bool[0]}  ${amt}   ${bool[0]}  department=${dep_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}

JD-TC-ServiceCreationByUserLogin-3

    [Documentation]  Create  a service for a valid user with service name same as another user

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User      deptId=${dep_id}
   
    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Create Service   ${SERVICE1}  ${description}   ${dur}   ${bool[0]}  ${amt}  ${bool[0]}  department=${dep_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}


JD-TC-ServiceCreationByUserLogin -UH1

    [Documentation]   Provider create a service for a User without login   

    ${resp}=  Create Service   ${SERVICE1}  ${description}   ${dur}  ${bool[0]}   ${amt}  ${bool[0]}  department=${dep_id}  provider=${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-ServiceCreationByUserLogin -UH2

    [Documentation]   Consumer  create a service for user

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME_E}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Create Service   ${SERVICE1}  ${description}   ${dur}   ${bool[0]}   ${amt}   ${bool[0]}  department=${dep_id}  provider=${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-ServiceCreationByUserLogin-UH3    

    [Documentation]  Create an already existing service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service    ${SERVICE1}  ${description}   ${dur}   ${bool[0]}   ${amt}  ${bool[0]}  department=${dep_id}  provider=${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SERVICE_CANT_BE_SAME}"


JD-TC-ServiceCreationByUserLogin-4

    [Documentation]  Create a service for a branch, Create same service for valid user

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${licId}  ${licname}=  get_highest_license_pkg
    FOR   ${a}  IN RANGE   0  ${length}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable   ${pkgId}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        Run Keyword If  "${pkgId}"=="${licId}"  Exit For Loop
    END

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${depid1}  ${resp.json()}

    ${resp}=  Get Department ById  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}  ${bool[0]}   ${servicecharge}  ${bool[0]}  department=${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
    ${ran int}=    Convert To Integer    ${ran int}
    ${B28_User1}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${B28_User1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state1}=  FakerLibrary.state   
    ${subdomains}=   get_subdomains   ${domain}
    log    ${subdomains}
    ${sublen}=   Get Length  ${subdomains}
    ${i}=  Random Int  min=0  max=${sublen-1}
    ${sub_domain_id}=  Set Variable  ${subdomains[${i}]['subdomainId']}

    ${PUSERNAME_U1}  ${u_id1} =  Create and Configure Sample User    deptId=${depid1}
    
    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Service   ${SERVICE1}  ${desc}   ${ser_duratn}  ${bool[0]}   ${servicecharge}  ${bool[0]}  department=${depid1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_sid1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${u_sid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}

