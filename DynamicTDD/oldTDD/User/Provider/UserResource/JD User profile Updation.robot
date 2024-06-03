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
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-Updateuserprofile-1
    [Documentation]  Create a user profile without details then update profile details with some details
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+550222
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
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
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+386346
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
    ${pin}=  get_pincode
    ${user_dis_name}=  FakerLibrary.last_name
    Set Suite Variable  ${user_dis_name}
    ${employee_id}=  FakerLibrary.last_name
    Set Suite Variable  ${employee_id}
    
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${emp_list}=  Create List 
    Set Suite Variable  ${emp_list}

    ${resp}=  User Profile Updation  ${EMPTY}  ${EMPTY}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  languagesSpoken=${emp_list}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${emp_list}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${emp_list}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${emp_list}

JD-TC-Updateuserprofile-2
    [Documentation]  Update a user profile with all details

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-Updateuserprofile-3
    [Documentation]  Update businessName and businessDesc of user profile with other details
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-Updateuserprofile-UH1
     [Documentation]  Update a user profile with another sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${sub_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id1}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_DIFFERENT_SUBDOMAIN}"

JD-TC-Updateuserprofile-UH2
    [Documentation]  Update a user profile with invalid user id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${USER_NOT_FOUND_WITH_ID}=  Format String  ${USER_NOT_FOUND_WITH_ID}  0
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${USER_NOT_FOUND_WITH_ID}

JD-TC-Updateuserprofile-UH3
     [Documentation]  Update a user profile with invalid sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  12345  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"

JD-TC-Updateuserprofile-UH4
     [Documentation]  Update a user profile for INACTIVE user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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
     ${pin}=  get_pincode
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=  EnableDisable User  ${u_id}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INACTIVE_PROVIDER}"

JD-TC-Updateuserprofile -UH5
     [Documentation]   Provider update a User profile without login      
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
     ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
 
JD-TC-Updateuserprofile -UH6
    [Documentation]   Consumer update a user profile
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

