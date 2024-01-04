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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-UpdateBusinessProfileByUserLogin-1
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
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+998811
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s

     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable   ${dep_id}   ${resp.json()['departments'][0]['departmentId']}        

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+587890
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
      ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${u_id}  ${resp.json()}
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${sub_domains}'
            # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateBusinessProfileByUserLogin-2

    [Documentation]  Upadte User profile with some details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${emp_list}=  Create List 
    Set Suite Variable  ${emp_list}

    ${resp}=  User Profile Updation  ${EMPTY}  ${EMPTY}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  languagesSpoken=${emp_list}  userSubdomain=${userSubDomain}   profileId=${u_p_id}  specialization=${emp_list}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${emp_list}  userSubdomain=${userSubDomain}   profileId=${u_p_id}  specialization=${emp_list}

***Comment***
JD-TC-UpdateBusinessProfileByUserLogin-2
    [Documentation]  Update a user profile with all details
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}
    Set Suite Variable  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}
    Set Suite Variable  ${Languages}

    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${bs_des}=  FakerLibrary.word
    Set Suite Variable  ${bs_des}

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}


JD-TC-UpdateBusinessProfileByUserLogin-3
    [Documentation]  Update businessName and businessDesc of user profile with other details
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings    ${resp.status_code}    200
    
    ${bs1}=  FakerLibrary.bs
    ${bs_des1}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs1}  ${bs_des1}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs1}  businessDesc=${bs_des1}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

JD-TC-UpdateBusinessProfileByUserLogin-UH1
     [Documentation]  Update a user profile with another sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${sud_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sud_domain_id1}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_DIFFERENT_SUBDOMAIN}"

JD-TC-UpdateBusinessProfileByUserLogin-UH2
     [Documentation]  Update a user profile with invalid user id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"

JD-TC-UpdateBusinessProfileByUserLogin-UH3
     [Documentation]  Update a user profile with invalid sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  000  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"

JD-TC-UpdateBusinessProfileByUserLogin-UH4
     [Documentation]  Update a user profile for INACTIVE user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3836855
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${address}=  get_address
     Set Suite Variable  ${address}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${location}=  FakerLibrary.city
     Set Suite Variable  ${location}
     ${state}=  FakerLibrary.state
     Set Suite Variable  ${state}

     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=  EnableDisable User  ${u_id}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INACTIVE_PROVIDER}"

JD-TC-UpdateBusinessProfileByUserLogin -UH5
     [Documentation]   Provider update a User profile without login      
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
     ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateBusinessProfileByUserLogin -UH6
    [Documentation]   Consumer update a user profile
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"