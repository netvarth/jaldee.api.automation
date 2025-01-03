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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py

*** Variables ***

${secid}     1
@{service_duration}   5   20

***Test Cases***

JD-TC-CreateUser-1

    [Documentation]  Create a user by branch login

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+55045300
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

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${lid}=  Create Sample Location
   
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336645
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
  
    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${countryCodes[0]}  ${PUSERNAME_U1}   ${userType[2]}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}        
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[2]}     
       
        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          ${dep_id}    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       1

    END

  
JD-TC-CreateUser-2

    [Documentation]  Create more users by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+336646
    clear_users  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
   
    ${pin1}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[0]}  ${PUSERNAME_U2}   ${userType[2]}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id1}  ${resp.json()['subdomain']}
    
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+336647
    Set Suite Variable  ${PUSERNAME_U3}
    clear_users  ${PUSERNAME_U3}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${location2}=  FakerLibrary.city
    ${state2}=  FakerLibrary.state 
    
    ${pin1}=  get_pincode
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${countryCodes[0]}  ${PUSERNAME_U3}   ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}
    
    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4
 
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U1}     

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${id}'   
        ...    Run Keywords
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname_A}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname_A} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_E}
    
        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id1}'   
        ...    Run Keywords
         ...    Should Be Equal As Strings  ${resp.json()[${i}]['firstName']}                           ${firstname1} 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                             ${lastname1} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U2}      
       
        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${u_id2}'   
        ...    Run Keywords
         ...    Should Be Equal As Strings  ${resp.json()[${i}]['firstName']}                           ${firstname2} 
        ...    Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                             ${lastname2} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U3}      
      
    END

JD-TC-CreateUser-3

    [Documentation]  Create a user for a different department by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()[0]['id']}

    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   ${sid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+336648
    clear_users  ${PUSERNAME_U4}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U4}   ${userType[0]}    deptId=${depid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id3}  ${resp.json()['subdomain']}

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  5
    
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U4}      
    END
    
JD-TC-CreateUser-4

    [Documentation]  Create a user for a different subdomain in same domain by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Set Suite Variable  ${sub_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+336649
    clear_users  ${PUSERNAME_U5}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
   
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U5}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sub_domain_id3}  ${resp.json()['subdomain']}

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  6
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U5}      
    END
    
JD-TC-CreateUser-5

    [Documentation]  Create a user for a different usertype(ASSISTANT) by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Set Suite Variable  ${sub_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+336849
    clear_users  ${PUSERNAME_U5}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U5}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  7

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U5}      
    END
   
JD-TC-CreateUser-6

    [Documentation]  Create a user for a different usertype(ADMIN) by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Set Suite Variable  ${sub_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+336850
    clear_users  ${PUSERNAME_U5}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
   
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U5}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id4}  ${resp.json()}

    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  8
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id4}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U5}      
    END

JD-TC-CreateUser-UH1

    [Documentation]  Create a user for a invalid subdomain by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sub_domain_id2}=  Random Int   min=100  max=200
    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336650
    clear_users  ${PUSERNAME_U6}

    ${SUBSECTOR}=   Format String  ${SUBSECTOR}  ${secid}   ${sub_domain_id2}

    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode

    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id4}  ${resp.json()}

JD-TC-CreateUser-UH2

    [Documentation]  Create a user for a invalid department by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${depid2}=  Random Int   min=100  max=200
    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336651
    clear_users  ${PUSERNAME_U6}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode

    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${depid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_DEPARTMENT}"

JD-TC-CreateUser-UH3

    [Documentation]  Create a user with already existing ph by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336649
    # clear_users  ${PUSERNAME_U6}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode

    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${MOBILE_NO_USED}"

JD-TC-CreateUser-UH4

    [Documentation]  Create a user with empty ph by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode

    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${EMPTY}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PHONENO_EMAIL_REQUIRED}"

JD-TC-CreateUser-UH5

    [Documentation]  Create a user with empty firstname by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336652
    clear_users  ${PUSERNAME_U6}
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode

    ${resp}=  Create User  ${EMPTY}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FIRST_NAME_REQUIRED}"

JD-TC-CreateUser-UH6

    [Documentation]  Create a user with empty lastname by branch login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336652
    clear_users  ${PUSERNAME_U6}
    ${firstname3}=  FakerLibrary.name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode  

    ${resp}=  Create User  ${firstname3}  ${EMPTY}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LAST_NAME_REQUIRED}"

JD-TC-CreateUser -UH7

    [Documentation]   Provider create a User without login  

    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+336652
    clear_users  ${PUSERNAME_U6}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    ${pin3}=  get_pincode  
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U6}   ${userType[0]}    deptId=${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-CreateUser -UH8

    [Documentation]   Consumer create a User

    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateUser -7

    [Documentation]   Disable User and check his queue state and service state(they are in disabled state) 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERNAME_E}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_E}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  30
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
   
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    
    ${location}=  FakerLibrary.city
    ${state}=  FakerLibrary.state

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+651122
    clear_users  ${PUSERNAME_E}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${pin1}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${p_id}=  get_acc_id  ${PUSERNAME_E}
    Set Suite Variable   ${p_id}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]} 
    
    ${SERVICE1}=  FakerLibrary.word
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=  FakerLibrary.name
    Set Suite Variable  ${SERVICE2}

    ${totalamt}=   FakerLibrary.Random Int  min=200  max=500
    ${totalamt}=  Convert To Number  ${totalamt}  1 
    Set Suite Variable  ${totalamt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${service_duration[0]}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${p1_id}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=    Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  EnableDisable User   ${u_id2}   ${toggle[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${queue_name}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}   1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}   10
    Should Be Equal As Strings  ${resp.json()[0]['queueState']}   ${Qstate[1]}    

    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${SERVICE2}    serviceDuration=${service_duration[0]}  notificationType=${notifytype[0]}   totalAmount=${totalamt}  status=${status[1]}  bType=${btype} 	  
    Verify Response List  ${resp}  1  name=${SERVICE1}    serviceDuration=${service_duration[0]}  notificationType=${notifytype[0]}   totalAmount=${totalamt}  status=${status[1]}  bType=${btype}  
  
JD-TC-CreateUser -UH9
    [Documentation]   Create user with international phone number

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${User1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${pin1}=  get_pincode  
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin1}  +${country_code}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"
    Should Be Equal As Strings  "${resp.json()}"  "${INVAID_USER_PHONE_NUMBER}"

JD-TC-CreateUser -UH10
    [Documentation]   Create 2 users with same phone number, different country codes.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${subdomain}  ${resp.json()['subSector']}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code1}    Generate random string    2    0123456789
    ${country_code1}    Convert To Integer  ${country_code1}
#     ${country_code2}    Generate random string    3    0123456789
#     ${country_code2}    Convert To Integer  ${country_code2}
    ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${User1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[1]}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}  
    ...    mobileNo=${User1}  dob=${dob1}  gender=${Genderlist[0]}  
    ...   userType=${userType[0]}  status=ACTIVE  email=${P_Email}${User1}.${test_mail}  
    ...   state=${state1}  deptId=${dep_id}  subdomain=${userSubDomain}
    Should Be Equal As Strings   ${resp.json()['city']}   ${city1}   ignore_case=True

    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${User1}101.${test_mail}   ${userType[0]}  ${pin2}  +${country_code1}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVAID_USER_PHONE_NUMBER}"

    # Should Be Equal As Strings  "${resp.json()}"  "${INVALID_COUNTRY_CODE}"

JD-TC-CreateUser -UH11
    [Documentation]   create user with empty country code

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${User1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${User1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${pin1}=  get_pincode

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${User1}.${test_mail}   ${userType[0]}  ${pin1}  ${EMPTY}  ${User1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUNTRY_CODEREQUIRED}"

JD-TC-CreateUser -8
    [Documentation]   create user with existing consumer's phone number

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # ${gender}=  Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${EMPTY}  ${dob}  ${gender}   ${EMPTY} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERPH0}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${CUSERPH0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERPH0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERPH0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${licId}  ${licname}=  get_highest_license_pkg
    # ${buser}=   Get branch by license   ${licId}
    # Set Suite Variable  ${buser}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    clear_users  ${CUSERPH0}
    ${pin3}=  get_pincode
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${CUSERPH0}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${CUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${CUSERPH0}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


# JD-TC-CreateUser -9
#     [Documentation]   create user with existing consumer's second phone number

#     ${PO_Number}    Generate random string    4    0123456789
#     ${PO_Number}    Convert To Integer  ${PO_Number}
#     ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
#     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#     ${firstname}=  FakerLibrary.name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  get_address
#     ${dob}=  FakerLibrary.Date
#     ${gender}=  Random Element    ${Genderlist}
#     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Activation  ${CUSERPH0}  1
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1  
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=   Get Business Profile
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

#     ${resp}=  Get Waitlist Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
#     Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
#     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
#     sleep  2s
#     ${dep_name1}=  FakerLibrary.bs
#     ${dep_code1}=   Random Int  min=100   max=999
#     ${dep_desc1}=   FakerLibrary.word  
#     ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id}  ${resp.json()}

#     clear_users  ${CUSERPH_SECOND}
#     ${pin3}=  get_pincode
#     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${CUSERPH_SECOND}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${CUSERPH_SECOND}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${u_id}  ${resp.json()}

#     ${resp}=  Get User By Id  ${u_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${CUSERPH_SECOND}

#     ${resp}=  Provider Logout
#     Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateUser -10
    [Documentation]   Update a consumer's phone number and create user with consumer's new phone number

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # ${gender}=  Random Element    ${Genderlist}
    # ${email}  Set Variable  ${C_Email}_${lastname}${CUSERPH0}.${test_mail}
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${email} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${email}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Consumer By Id  ${CUSERPH0}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

    # ${PO_Number1}    Generate random string    3    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${newNo}=  Evaluate  ${PUSERNAME33}+${PO_Number1}
    # ${newNo}=  Evaluate  ${PUSERNAME33}+678

    # ${resp}=  Send Verify Login Consumer   ${newNo}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Verify Login Consumer   ${newNo}  5
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${newNo}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer By Id  ${newNo}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${CUSERPH0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERPH0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERPH0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${newNo}=  Evaluate  ${CUSERNAME}+${PO_Number}

    # Need to update provider consumer phone number here!
    # Set Test Variable  ${consumerEmail}  ${CUSERNAME4}${C_Email}.${test_mail}
    
    ${resp}=    Update ProviderConsumer    ${cid1}    phoneNo=${newNo}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=   Get Business Profile
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    clear_users  ${newNo}
    ${pin3}=  get_pincode
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${newNo}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[1]}  ${newNo}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${newNo}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateUser -UH12
    [Documentation]   create a user with existing independent SP's(Provider's) phone number.

    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

#     clear_users  ${newNo}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${pin}=  get_pincode
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME8}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME8}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${MOBILE_NO_USED}"

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateUser -11
    [Documentation]   sign up a user(admin) without email, update phone number and signup another user(admin) with previous user's old phone number.

    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3456
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${pin}=  get_pincode
  
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+3457
    clear_users  ${PUSERPH1}
  
    ${resp}=  Update User   ${u_id}   ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${countryCodes[1]}  ${PUSERPH1}  ${countryCodes[1]}  ${PUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateUser -12
    [Documentation]   sign up a user(provider) without email, update phone number and signup another user(provider) with previous user's old phone number.

    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3458
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
 
    ${whpnum}=  Evaluate  ${PUSERNAME}+345245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+345345


    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+3459
    clear_users  ${PUSERPH1}
    
    ${resp}=  Update User   ${u_id}   ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH1}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateUser -13
    [Documentation]   sign up a user(admin), update phone number to empty and signup another user(admin) with previous user's old phone number.

    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    # ${PO_Number}    Generate random string    7    123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+3456789
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${PO_Number}    Generate random string    4    123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+4567
    clear_users  ${PUSERPH1}
   
    ${resp}=  Update User   ${u_id}   ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${PHONE_NUMBER_CAN_NOT_REMOVE_NO_EMAIL}
    # ${resp}=  Get User By Id  ${u_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${EMPTY}

    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
  
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id}  ${resp.json()}

    # ${resp}=  Get User By Id  ${u_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${resp}=  Provider Logout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateUser -14
    [Documentation]   sign up a user(provider), update phone number to empty and signup another user(provider) with previous user's old phone number.

    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    # ${PO_Number}    Generate random string    4    123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+4568
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
  
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${PO_Number}    Generate random string    4    123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+3667
    clear_users  ${PUSERPH1}
   
    ${resp}=  Update User   ${u_id}   ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${EMPTY}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${PHONE_NUMBER_CAN_NOT_REMOVE_NO_EMAIL}

    # ${resp}=  Get User By Id  ${u_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${EMPTY}

    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${address}=  get_address
    # ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
  
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id}  ${resp.json()}

    # ${resp}=  Get User By Id  ${u_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}

    # ${resp}=  Provider Logout
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-CreateUser-UH16
    [Documentation]  Create user with invalid whatsapp number
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${subdomain}  ${decrypted_data['subSector']}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomainId']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    # clear_queue      ${HLPUSERNAME18}
    # clear_service    ${HLPUSERNAME18}
    clear_customer   ${HLPUSERNAME18}

    ${pid}=  get_acc_id  ${HLPUSERNAME18}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
   
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id54}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME18}+1000440022
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum}=  Evaluate  ${HLPUSERNAME18}+336250
    ${tlgnum}=  Evaluate  ${HLPUSERNAME18}+336351

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${ph1}  ${dep_id54}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  00000  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVAID_WHATSAPP_NUMBER}
    # Set Test Variable  ${u_id54}  ${resp.json()}
    # ${resp}=  Get User By Id  ${u_id54}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id54}  firstName=${firstname}  lastName=${lastname}   mobileNo=${ph1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${ph1}.${test_mail}  city=${city}  state=${state}  pincode=${pin}   deptId=${dep_id54}  subdomain=${userSubDomain}
    # Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${EMPTY} 
    # Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    # Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum} 
    # Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
  
JD-TC-CreateUser-16
    [Documentation]  Create user with already used whatsapp number
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${subdomain}  ${decrypted_data['subSector']}
    # Set Test Variable  ${subdomain}  ${resp.json()['subSector']}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomainId']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    # clear_queue      ${HLPUSERNAME18}
    # clear_service    ${HLPUSERNAME18}
    clear_customer   ${HLPUSERNAME18}

    ${pid}=  get_acc_id  ${HLPUSERNAME18}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

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
    Set Test Variable  ${dep_id55}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME18}+1000211000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum}=  Evaluate  ${HLPUSERNAME18}+336245
    ${tlgnum}=  Evaluate  ${HLPUSERNAME18}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id55}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id55}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id55}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id55}  firstName=${firstname}  lastName=${lastname}   mobileNo=${ph1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${ph1}.${test_mail}   state=${state}  pincode=${pin}   deptId=${dep_id55}  subdomain=${userSubDomain}
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings   ${resp.json()['city']}   ${city}   ignore_case=True

    ${ph2}=  Evaluate  ${HLPUSERNAME18}+1000212010
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph2}  ${dep_id55}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id57}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id57}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id57}  firstName=${firstname}  lastName=${lastname}   mobileNo=${ph2}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${ph2}.${test_mail}   state=${state}  pincode=${pin}   deptId=${dep_id55}  subdomain=${userSubDomain}
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${whpnum} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${tlgnum} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings   ${resp.json()['city']}   ${city}   ignore_case=True   
   

JD-TC-CreateUser-UH13
    [Documentation]  Create user without countrycode in whatsapp
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${HLPUSERNAME18}
    # clear_service    ${HLPUSERNAME18}
    clear_customer   ${HLPUSERNAME18}

    ${pid}=  get_acc_id  ${HLPUSERNAME18}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    Set Test Variable  ${dep_id55}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME18}+1000440020
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum}=  Evaluate  ${HLPUSERNAME18}+336246
    ${tlgnum}=  Evaluate  ${HLPUSERNAME18}+336347

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id55}  ${sub_domain_id}  ${bool[0]}  ${EMPTY}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${COUNTRY_CODEREQUIRED}
   
  
JD-TC-CreateUser-UH14
    [Documentation]  Create user without country code in telegram number
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${HLPUSERNAME18}
    # clear_service    ${HLPUSERNAME18}
    clear_customer   ${HLPUSERNAME18}

    ${pid}=  get_acc_id  ${HLPUSERNAME18}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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
    Set Test Variable  ${dep_id55}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME18}+1000440021
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${whpnum}=  Evaluate  ${HLPUSERNAME18}+336248
    ${tlgnum}=  Evaluate  ${HLPUSERNAME18}+336349

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id55}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${EMPTY}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${COUNTRY_CODEREQUIRED}

JD-TC-CreateUser-UH15
    [Documentation]  Create a user with UserType as consumer
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Create Sample Service For User   ${Service1}   ${dep_id}   ${u_id}
     ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()[0]['id']} 
   
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+336651
    clear_users  ${PUSERNAME_U4}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[3]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      Invalid user

   
JD-TC-CreateUser-17
    [Documentation]  Create a user with UserType as support
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()[0]['id']} 
   
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+336652
    clear_users  ${PUSERNAME_U4}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[4]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  5
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U4}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob3}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[4]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U4}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city3}   ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]} 
    END
    
JD-TC-CreateUser-18
    [Documentation]  Create a user with UserType as manager
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()[0]['id']} 
   
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+336653
    clear_users  ${PUSERNAME_U4}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[5]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  5
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U4}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob3}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[5]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U4}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city3}  ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]} 
    END

JD-TC-CreateUser-19
    [Documentation]  Create a user with UserType as marketting
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()[0]['id']} 
   
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+336654
    clear_users  ${PUSERNAME_U4}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[6]}  ${pin3}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    ${resp}=  Get User Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  5
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${u_id3}'  
        ...    Run Keywords 
        ...    Should Be Equal As Strings       ${resp.json()[${i}]['firstName']}                       ${firstname3}       
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['lastName']}                        ${lastname3} 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['mobileNo']}                        ${PUSERNAME_U4}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['dob']}                             ${dob3}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['gender']}                          ${Genderlist[0]}      
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['userType']}                        ${userType[6]}     
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['status']}                          ACTIVE    
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['email']}                           ${P_Email}${PUSERNAME_U4}.${test_mail}  
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['city']}                            ${city3}   ignore_case=True
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['state']}                           ${state3}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['deptId']}                          0 
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['subdomain']}                       0
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['admin']}                           ${bool[0]} 
    END
    


JD-TC-CreateUser-20

    [Documentation]   create 10 users for a multi user account.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME10}'
                clear_users  ${user_phone}
            END
        END
    END

    @{u_ids}=  Create List

    FOR   ${i}  IN RANGE   0   10

        ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${u_id}=  Create Sample User  admin=${bool[0]}
        Set Test Variable   ${u_id${i}}   ${u_id}
        Append To List   ${u_ids}  ${u_id${i}}

        ${resp}=  Get User By Id  ${u_id${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${BUSER_U1${i}}  ${resp.json()['mobileNo']}

        ${resp}=  Provider Logout
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  SendProviderResetMail   ${BUSER_U1${i}}
        Should Be Equal As Strings  ${resp.status_code}  200

        @{resp}=  ResetProviderPassword  ${BUSER_U1${i}}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
        Should Be Equal As Strings  ${resp[0].status_code}  200
        Should Be Equal As Strings  ${resp[1].status_code}  200

        ${resp}=  Encrypted Provider Login  ${BUSER_U1${i}}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  ProviderLogout
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200


    END

    Log List   ${u_ids}



