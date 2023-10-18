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

JD-TC-GetManagerlistofUser-1

    [Documentation]  Create User With Roles And Scope then update his manager and verify the list.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME50}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['roleName']}

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
        IF   not '${user_phone}' == '${MUSERNAME50}'
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

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  isDefault=${bool[1]}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.${test_mail}   ${userType[0]}  ${pin1}  
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
    # Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}  ${bool[0]}
    
    ${u_id2}=  Create Sample User 
    Set Suite Variable  ${u_id2}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${manager_ids}=  Create List   ${u_id2}

    ${resp}=  Update Managers To user  ${u_id1}  ${manager_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Manager List of User  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200