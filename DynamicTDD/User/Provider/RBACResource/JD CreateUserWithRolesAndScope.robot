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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-CreateUserWithRolesAndScope-1

    [Documentation]  Create User With Roles And Scope for an existing provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}  ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}  ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

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
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  isDefault=${bool[1]}
    ...    capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

    
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  isDefault=${bool[1]}
    ...    capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Update User With Roles And Scope  ${u_id1}  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}


JD-TC-CreateUserWithRolesAndScope-2

    [Documentation]  Create multiple Users With same Role for an existing provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME2}+350245
    ${tlgnum}=  Evaluate  ${USERNAME2}+356355

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  isDefault=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME2}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

JD-TC-CreateUserWithRolesAndScope-3

    [Documentation]  Create User With Role and location scope.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME60}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${role_name1}  ${resp.json()[0]['roleName']}
    Set Test Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${locId2}=  Create Sample Location

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
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME60}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${locations}=  Create List  ${locId2}
    ${user_scope}=  Create Dictionary   businessLocations=${locations}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  isDefault=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['scope']['businessLocations'][0]}   ${locId2}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

JD-TC-CreateUserWithRolesAndScope-4

    [Documentation]  Create User With multiple Roles and verify the default role without any scope.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${user_scope}=  Create Dictionary  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[0]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${role2}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  ${role2}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}  ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}

    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}       ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}     ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability2}

JD-TC-CreateUserWithRolesAndScope-5

    [Documentation]  Create User With multiple Roles and multiple scope.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${locId2}=  Create Sample Location

    ${locations}=  Create List  ${locId2}
    ${user_scope}=  Create Dictionary  
    ${user_scope1}=  Create Dictionary   businessLocations=${locations}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  isDefault=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${role2}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  isDefault=${bool[0]}
    ...   scope=${user_scope1}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  ${role2}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id3}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name3}

    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['id']}       ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['roleName']}     ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['defaultRole']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][1]['capabilities']}     ${capability2}


JD-TC-CreateUserWithRolesAndScope-6

    [Documentation]  add create loan capability to a bussiness head role.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${capabilities}=  Create List   ${rbac_capabilities[0]}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  
    ...    capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${cap1}=  Set Variable    ${capability1}
    Append To List  ${cap1}  ${rbac_capabilities[0]}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${cap1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}


JD-TC-CreateUserWithRolesAndScope-UH1

    [Documentation]  Create User With same role multiple times.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${user_scope}=  Create Dictionary  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[0]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-CreateUserWithRolesAndScope-UH2

    [Documentation]  Create User With invalid location id as scope.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${locId2}=  Random Int   min=100000   max=200000

    ${locations}=  Create List  ${locId2}
    ${user_scope}=  Create Dictionary   businessLocations=${locations}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  isDefault=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1} 

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    
JD-TC-CreateUserWithRolesAndScope-UH3

    [Documentation]  Create User With another providers location id as scope.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  ProviderLogout 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME41}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME41}'
            clear_users  ${user_phone}
        END
    END

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355

    ${locations}=  Create List  ${locId}
    ${user_scope}=  Create Dictionary   businessLocations=${locations}
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  isDefault=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}  

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    