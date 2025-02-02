***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

@{emptylist}

***Test Cases***

JD-TC-UpdateUserprofile-1

     [Documentation]  Create a user profile with details
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Suite Variable  ${iscorp_subdomains}
     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  generate_firstname
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+550221
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
     ${resp}=  Enable Disable Department  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336845
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
     Set Suite Variable  ${pin}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}   employeeId=${employee_id}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}

     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  
    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['businessName']}    ${bs}
    Should Be Equal As Strings    ${resp.json()['businessDesc']}    ${bs_des}
    Should Be Equal As Strings    ${resp.json()['languagesSpoken']}      ${Languages}
    Should Be Equal As Strings    ${resp.json()['userSubdomain']}      ${sub_domain_id}
    Should Be Equal As Strings    ${resp.json()['profileId']}      ${u_p_id}



JD-TC-UpdateUserprofile-2

     [Documentation]  Create a user profile without details
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336848
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
     ${employee_id2}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id2}
     
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id2}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}   employeeId=${employee_id2}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
      
     ${emp_list}=  Create List 
     Set Suite Variable  ${emp_list}

    ${resp}=  User Profile Updation  ${EMPTY}  ${EMPTY}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

 
JD-TC-UpdateUserprofile-3
     [Documentation]  Create a user profile with some details
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3736849
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
     ${employee_id3}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id3}

     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id3}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id3}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}




JD-TC-UpdateUserprofile-UH2
     [Documentation]  Create a user profile with invalid user id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336851
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
     ${employee_id4}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id4}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id4}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id4}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
    ${USER_NOT_FOUND_WITH_ID}=  Format String  ${USER_NOT_FOUND_WITH_ID}  0

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  000
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${USER_NOT_FOUND_WITH_ID}"

JD-TC-UpdateUserprofile-UH3
     [Documentation]  Create a user profile for ASSISTANT type user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336852
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
    ${employee_id5}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id5}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id5}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id5}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_USERTYPE}"

JD-TC-UpdateUserprofile-UH4
     [Documentation]  Create a user profile for already created user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336853
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
     ${employee_id6}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id6}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id6}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id6}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
     
     ${resp}=  User Profile Creation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   422
     Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_PROFILE_ALREADY_CREATED}"


JD-TC-UpdateUserprofile-UH5
     [Documentation]  Create a user profile for INACTIVE user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336855
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
     ${employee_id7}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id7}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id7}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id7}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${resp}=  EnableDisable User  ${u_id}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INACTIVE_PROVIDER}"

JD-TC-CreateUserprofile -UH8
     [Documentation]   Provider create a User profile without login      
     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
     ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-CreateUserprofile -UH9
    [Documentation]   Consumer create a user profile

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}


     ${PH_Number}    Random Number          digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.last_name
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}${firstName}.${test_mail}

    ${resp}=  AddCustomer  ${primaryMobileNo}  firstName=${firstName}   lastName=${lastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${email}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${primaryMobileNo}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullastName}   Set Variable    ${firstName} ${lastName}
    Set Test Variable  ${fullastName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-UpdateUserprofile-UH7
     [Documentation]  Create a user profile for defaultAdminUser=true user
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id}  ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_PROFILE_NOT_FOUND}"


JD-TC-UpdateUserprofile-UH1
     [Documentation]  Create a user profile with another sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336823
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
     ${employee_id8}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id8}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id8}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id8}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
     Set Suite Variable  ${sub_domain_id1}   ${iscorp_subdomains[1]['subdomainId']}
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  ${sub_domain_id1}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_DIFFERENT_SUBDOMAIN}"


JD-TC-UpdateUserprofile-UH6
     [Documentation]  Create a user profile with invalid sub domain id
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336854
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
     ${employee_id9}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id9}
     
     # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  employeeId=${employee_id9}  bProfilePermitted=${boolean[1]}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERNAME_U1}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}   pincode=${pin}    deptId=${dep_id}     employeeId=${employee_id9}  bProfilePermitted=${boolean[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${bs}=  FakerLibrary.bs
     ${bs_des}=  FakerLibrary.word
  
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${EMPTY}  ${EMPTY}  -11  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"
