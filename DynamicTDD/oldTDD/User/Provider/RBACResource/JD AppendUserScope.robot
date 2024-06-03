*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}
${phone}     5555512340


*** Test Cases ***

JD-TC-AppendUserScope-1

    [Documentation]  append user role(Bussiness head) and scope to an existing user without any scope.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${locId1}=  Create Sample Location
    Set Suite Variable   ${locId1}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME19}'
                clear_users  ${user_phone}
            END
        END
    END

     ${u_id1}=  Create Sample User 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id2}=  Create Sample User 
    Set Suite Variable  ${u_id2}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  ${u_id2}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

JD-TC-AppendUserScope-2

    [Documentation]  append user scope to an existing user with another location in scope.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    

    ${loc_ids}=  Create List   ${locId1}

    ${user_scope}=  Create Dictionary   businessLocations=${loc_ids}
    
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['scope']['businessLocations'][0]}   ${locId1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}


JD-TC-AppendUserScope-3

    [Documentation]   append user role('Sales head').

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${role1}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}   
    ${user_roles}=  Create List   ${role1} 

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}
   
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability1}


JD-TC-AppendUserScope-4

    [Documentation]   append user role(Branch Manager and Branch Operation Head(default role)).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  
    ${role2}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}   defaultRole=${bool[1]}
    ${user_roles}=  Create List   ${role1}   ${role2}

    ${user_ids}=  Create List   ${u_id1}   

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability4}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['capabilities']}     ${capability2}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}
   
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['capabilities']}     ${capability1}


JD-TC-AppendUserScope-5

    [Documentation]   append user role(Branch Credit Head, Sales Executive Sales Officer).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  
    ${role2}=  Create Dictionary   id=${role_id6}  roleName=${role_name6} 
    ${role3}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  
    ${user_roles}=  Create List   ${role1}   ${role2}  ${role3}

    ${user_ids}=  Create List   ${u_id1}   

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability5}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability6}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][2]['capabilities']}     ${capability7}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}
   
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][3]['capabilities']}     ${capability3}

    Should Be Equal As Strings  ${resp.json()['userRoles'][4]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][4]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][4]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][4]['capabilities']}     ${capability4}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][5]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][5]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][5]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][5]['capabilities']}     ${capability2}
    
    Should Be Equal As Strings  ${resp.json()['userRoles'][6]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][6]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][6]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][6]['capabilities']}     ${capability1}


JD-TC-AppendUserScope-6

    [Documentation]  append user role without role name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${EMPTY}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability1}
    
JD-TC-AppendUserScope-7

    [Documentation]  append user role with extra capability.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${capabilities}=  Create List   ${rbac_capabilities[15]}

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cap1}=  Set Variable    ${capability1}
    Append To List  ${cap1}  ${rbac_capabilities[0]}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${cap1}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability1}
    
JD-TC-AppendUserScope-8

    [Documentation]  append user role without setting default role ,then check the default role.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  



JD-TC-AppendUserScope-9

    [Documentation]  create a user without any role, then append sales officer role and 
    ...  create partner .then append bussiness head role to the same user, 
    ...  then try to disable partner.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Test Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Test Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Test Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Test Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Test Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ${user_roles}=  Create List   ${role1}
    ${user_ids}=  Create List    ${provider_id1}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME125}'
                clear_users  ${user_phone}
            END
        END
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${u_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List  ${u_id1}   

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${USERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}

    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability7}

    ${Salesofficer}=    Create Dictionary    id=${u_id1}   name=${firstName}    isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${u_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AppendUserScope-10

    [Documentation]  create a user without any role, then append sales officer role and 
    ...  create loan .then append reject loan capability to sales officer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Test Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Test Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Test Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Test Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Test Variable  ${capability5}  ${resp.json()[4]['capabilityList']}
    Set Test Variable  ${capability}  ${resp.json()[4]['capabilityList'][8]}

    Set Test Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Test Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Test Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ${user_roles}=  Create List   ${role1}
    ${user_ids}=  Create List    ${provider_id1}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME127}'
                clear_users  ${user_phone}
            END
        END
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME2}  ${resp.json()['mobileNo']}

    ${loc_ids}=  Create List   ${locId}
    ${branch_list}=  Create List   ${branchId1}
    ${user_scope}=  Create Dictionary    businessLocations=${loc_ids}   branches=${branch_list}
    
    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${usr_list}=   Create List   ${u_id1}
    ${user_scope}=  Create Dictionary   users=${usr_list}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${USERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Test Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Test Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Test Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Test Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Test Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 

    ${resp}=  Get Loan Application SP Internal Status   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${sp_status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${sp_status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${USERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${firstname}   lastName=${lastname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${custid}    ${resp.json()[0]['id']}
    Set Test Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Test Variable    ${email}  ${lastname}${C_Email}.${test_mail}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid}    ${resp.json()['id']}
    Set Test Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}    

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....sales officer cannot have capability to reject loan.....

    ${resp}=  Reject Loan Application   ${loanuid}  ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${NO_PERMISSION_FOR_REQUEST}

# .....add reject loan capability to sale officer, then check.....

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List   ${capability}

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cap1}=  Set Variable    ${capability7}
    Append To List  ${cap1}  ${capability}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${cap1}
    
    ${resp}=  Reject Loan Application   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['applicationStatus']}   ${LoanApplicationStatus[3]}
 
JD-TC-AppendUserScope-11

    [Documentation]  create multiple branches in one loaction and add one branch in 
    ...   sales offciers scope, then try to create loan in that loaction and 
    ...   verify the branch in which the loan created.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME129}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Test Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Test Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Test Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Test Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Test Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Test Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Test Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Test Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ${user_roles}=  Create List   ${role1}
    ${user_ids}=  Create List    ${provider_id1}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME129}'
                clear_users  ${user_phone}
            END
        END
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchId2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME2}  ${resp.json()['mobileNo']}

    ${loc_ids}=  Create List   ${locId}
    ${branch_list}=  Create List   ${branchId1}
    ${user_scope}=  Create Dictionary    businessLocations=${loc_ids}   branches=${branch_list}
    
    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${usr_list}=   Create List   ${u_id1}
    ${user_scope}=  Create Dictionary   users=${usr_list}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${USERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Test Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Test Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Test Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Test Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Test Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 

    ${resp}=  Get Loan Application SP Internal Status   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${sp_status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${sp_status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${USERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${firstname}   lastName=${lastname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${custid}    ${resp.json()[0]['id']}
    Set Test Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Test Variable    ${email}  ${lastname}${C_Email}.${test_mail}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid}    ${resp.json()['id']}
    Set Test Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}    

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AppendUserScope-12

    [Documentation]  create multiple branches in multiple loactions and add one branch in 
    ...   sales offciers scope, then try to create loan in another branch loaction and 
    ...   verify the branch in which the loan created.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   



JD-TC-AppendUserScope-13

    [Documentation]  create a branch in one location and append another location in 
    ...   sales officers scope, then try to create loan with location in sales officers scope.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

JD-TC-AppendUserScope-14

    [Documentation]  create a branch in one location and append another location in 
    ...   sales officers scope, then try to create loan with location in branch.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

JD-TC-AppendUserScope-UH1

    [Documentation]  append same role again.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${role2}=  Create Dictionary   id=${role_id1}  roleName=${role_name1} 
    ${user_roles}=  Create List   ${role1}  ${role2}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DONT_GIVE_SAME_ROLE_ID}

JD-TC-AppendUserScope-UH2

    [Documentation]  append user role with invalid role id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${invalid_role}=  Random Int   min=100000   max=200000

    ${role1}=  Create Dictionary   id=${invalid_role}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_ROLE_ID}


JD-TC-AppendUserScope-UH3

    [Documentation]  append user role with another providers user id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
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
            IF   not '${user_phone}' == '${PUSERNAME64}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${invalid_role}=  Random Int   min=100000   max=200000

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id1}   ${u_id}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${NO_PERMISSION}


JD-TC-AppendUserScope-UH4

    [Documentation]  append user role with another providers user id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${invalid_uid}=  Random Int   min=100000   max=200000

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id1}   ${invalid_uid}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_USER_ID}


JD-TC-AppendUserScope-UH5

    [Documentation]  append user role with another providers location id in the scope.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${locId1}=  Create Sample Location

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${loc_ids}=  Create List   ${locId1}

    ${user_scope}=  Create Dictionary   businessLocations=${loc_ids}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  scope=${user_scope}
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_BUSS_LOC_ID}


JD-TC-AppendUserScope-UH6

    [Documentation]  append user roles without login.

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AppendUserScope-UH7

    [Documentation]  append user roles with consumer login.

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ${user_roles}=  Create List   ${role1}  

    ${user_ids}=  Create List   ${u_id1} 

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-AppendUserScope-UH8

    [Documentation]  create a user without any role, then append sales officer role and 
    ...  create partner then try to activate partner.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME126}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Test Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Test Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME126}'
                clear_users  ${user_phone}
            END
        END
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${u_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${USERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Activate Partner    ${partuid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${NOT_ADMIN}



