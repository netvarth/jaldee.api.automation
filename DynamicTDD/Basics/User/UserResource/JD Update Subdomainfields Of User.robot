*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${subdomain_len}  0
@{countryCode}   91  +91  48 

*** Test Cases ***

JD-TC-UpdateSubDomainVirtualFieldOfUser-1
    [Documentation]   update domain virtual fields  of a valid provider
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[3]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[3]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[3]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+770017
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
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
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
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+776645
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin1}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
     
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}   bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
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
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields_OfUser  ${fields.json()}
    Set Suite Variable  ${virtual_fields}
    ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields}  ${sub_domain_id}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${virtual_fields}=  json.dumps  ${virtual_fields}
    Log  ${virtual_fields}

    ${resp}=  Get User Profile  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${fields_businessprofile}  ${resp.json()['subDomainVirtualFields'][0]['${sub_domains}']}
    ${fields_businessprofile}=  json.dumps  ${fields_businessprofile} 
    Should Be Equal As Strings  ${virtual_fields}  ${fields_businessprofile}

JD-TC-UpdateSubDomainVirtualFieldOfUser-UH1
    [Documentation]  Update Sub-domain  virtual fields without login
    ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields}  ${sub_domain_id}  ${u_id}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
    
JD-TC-UpdateSubDomainVirtualFieldOfUser-UH2
    [Documentation]   Update Sub-domain virtual fields  by  login as consumer
    ${resp}=    ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields}  ${sub_domain_id}  ${u_id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-UpdateSubDomainVirtualFieldOfUser-UH3
#     [Documentation]   update Sub-domain  virtual fields  of a valid user with another domain virtual fields
    
#     ${iscorp_subdomains}=  get_iscorp_subdomains  1
#     Log  ${iscorp_subdomains}
#     Set Test Variable  ${domains1}  ${iscorp_subdomains[4]['domain']}
#     Set Test Variable  ${sub_domains1}   ${iscorp_subdomains[4]['subdomains']}
#     Set Suite Variable  ${sud_domain_id1}   ${iscorp_subdomains[4]['subdomainId']}
#     ${firstname_A}=  FakerLibrary.first_name
#     Set Suite Variable  ${firstname_A}
#     ${lastname_A}=  FakerLibrary.last_name
#     Set Suite Variable  ${lastname_A}
#     ${MUSERNAME_R}=  Evaluate  ${PUSERNAME}+774510
#     ${highest_package}=  get_highest_license_pkg
#     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains1}  ${sub_domains1}  ${MUSERNAME_R}    ${highest_package[0]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${MUSERNAME_R}  0
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${MUSERNAME_R}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Encrypted Provider Login  ${MUSERNAME_R}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_R}${\n}

#     ${id1}=  get_id  ${MUSERNAME_R}
#     ${bs}=  FakerLibrary.bs
#     ${resp}=  Toggle Department Enable
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep  2s
#     ${resp}=  Get Departments
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}
#     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+776678
#     clear_users  ${PUSERNAME_U2}
#     ${firstname}=  FakerLibrary.name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  get_address
#     ${dob}=  FakerLibrary.Date
#     ${pin2}=  get_pincode
     
#     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id1}  ${sud_domain_id1}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}   bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${u_id1}  ${resp.json()}

#     ${resp}=  Get specializations Sub Domain  ${domains1}  ${sub_domains1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     ${spec}=  get_specs  ${resp.json()}
#     Log  ${spec}

#     ${resp}=  Get Spoke Languages
#     Should Be Equal As Strings    ${resp.status_code}   200 
#     ${Languages}=  get_Languagespoken  ${resp.json()}
#     Log  ${Languages}

#     ${bs}=  FakerLibrary.bs
#     ${bs_des}=  FakerLibrary.word

#     ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sud_domain_id1}  ${u_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

#     # ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
#     # Log  ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Set Test Variable   ${d}  ${resp.json()['sector']}
#     # Set Test Variable   ${sd}  ${resp.json()['subSector']}

#     ${fields}=   Get subDomain level Fields  ${domains1}  ${sub_domains1}
#     Log  ${fields.json()}
#     Should Be Equal As Strings    ${fields.status_code}   200
#     ${virtual_fields1}=  get_Subdomainfields_OfUser  ${fields.json()}

#     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields1}  ${sub_domain_id}  ${u_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_DOM_VIRTUAL_FIELDS}"

JD-TC-UpdateSubDomainVirtualFieldOfUser-UH4
    [Documentation]   update Sub-domain  virtual fields  of a valid user with invalid user id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields}  ${sub_domain_id}  000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"

JD-TC-UpdateSubDomainVirtualFieldOfUser-UH5
    [Documentation]   update Sub-domain  virtual fields  of a valid user with invalid sub domain id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Sub_Domain_Level Of User  ${virtual_fields}  000  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"