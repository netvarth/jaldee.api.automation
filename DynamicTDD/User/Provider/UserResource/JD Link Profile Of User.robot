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


*** Variables ***
@{emptylist} 


***Test Cases***

JD-TC-LinkProfile-1
     [Documentation]  Link a user profile with another account

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660218
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446445
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
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
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660217
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446446
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
   
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

JD-TC-LinkProfile-2
     [Documentation]  Link a user's profile with another account's user Then changing the user profile and check its reflected in other account's user profile
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660228
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446455
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${location}=  FakerLibrary.city
     Set Suite Variable  ${location}
     ${state}=  FakerLibrary.state
     Set Suite Variable  ${state}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sub_domain_id1}  ${resp.json()['subdomain']}
     
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

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id1}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id1}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660229
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446456
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
    
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

     ${resp}=  Get User By Id  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${sub_domain_id2}  ${resp.json()['subdomain']}
          

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Should Be Equal As Strings    ${resp.status_code}    200
    ${bs1}=  FakerLibrary.bs
    ${bs_des1}=  FakerLibrary.word
    
    ${emp_list}=  Create List 
    Set Suite Variable  ${emp_list}

    ${resp}=  User Profile Updation  ${bs1}  ${bs_des1}  ${emp_list}  ${emp_list}  ${sub_domain_id2}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}
     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs1}  businessDesc=${bs_des1}  languagesSpoken=${emp_list}  userSubdomain=${sub_domain_id2}   profileId=${u_p_id}  specialization=${emp_list}

JD-TC-LinkProfile-UH1
     [Documentation]  Link a user profile with another account's user..that user is INACTIVE
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
  
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660222
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446449
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660223
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446450
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

     ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${INACTIVE_PROVIDER}"
     
JD-TC-LinkProfile-3
     [Documentation]  Link a INACTIVE user's profile with another account's user
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660224
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446451
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=  EnableDisable User  ${u_id}  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660225
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446452
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
    
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}


JD-TC-LinkProfile-4
     [Documentation]  Link a user profile with another account's user..that user has already a profile
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660220
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446447
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660221
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446448
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
    
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

    ${bs1}=  FakerLibrary.bs
    ${bs_des1}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs1}  ${bs_des1}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${u_p_id2}  ${resp.json()['profileId']}

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
     ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

JD-TC-LinkProfile -UH2
     [Documentation]   Provider link a User without login      
     ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-LinkProfile -UH3
    [Documentation]   Consumer link a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-LinkProfile-UH4
     [Documentation]  link a user with invalid user id by branch login
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Link Profile  000  ${u_p_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"


JD-TC-LinkProfile-UH5
     [Documentation]  Again Link a user's profile with another account's user
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660226
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446453
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660227
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446454
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
    
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Link Profile  ${u_id1}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_PROFILE_ALREADY_LINKED}"
    
JD-TC-LinkProfile-6
     [Documentation]  Link a user's profile with another account's user then another provider trying to link profile to same user
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660230
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446457
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
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

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660231
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446458
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

     ${bs1}=  FakerLibrary.bs
    ${bs_des1}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs1}  ${bs_des1}  ${emp_list}  ${emp_list}  ${sub_domain_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${u_p_id1}  ${resp.json()['profileId']}

    ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660232
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446459
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
   
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Link Profile  ${u_id2}  ${u_p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get User Profile  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}


    ${resp}=  Link Profile  ${u_id2}  ${u_p_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get User Profile  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs1}  businessDesc=${bs_des1}  languagesSpoken=${emp_list}  userSubdomain=${sub_domain_id}   profileId=${u_p_id1}  specialization=${emp_list}

JD-TC-LinkProfile-UH6
     [Documentation]  link a user with invalid user profile id by branch login
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+660233
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_A}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_A}${\n}
     Set Suite Variable  ${MUSERNAME_A}
     ${id1}=  get_id  ${MUSERNAME_A}
     Set Suite Variable  ${id1}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+446462
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     
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
    Set Suite Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs_des}  languagesSpoken=${Languages}  userSubdomain=${sub_domain_id}   profileId=${u_p_id}  specialization=${spec}

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname_B}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_B}
     ${lastname_B}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_B}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+660234
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+446463
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     
     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}
     ${resp}=  Link Profile  ${u_id1}  000
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_PROFILE_NOT_FOUND}"


