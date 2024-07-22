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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}

*** Test Cases ***

JD-TC-CreateBooking_Appointment-1

    [Documentation]   Create Appointment Booking.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['bookingRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Booking RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['bookingRbac']}  ${bool[1]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capabilityList1}  ${resp.json()[0]['capabilityList']}

    ${resp}=  Get Capabilities By Feature       ${rbac_feature[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Capa_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${Capa_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${Capa_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Capa_name2}  ${resp.json()[1]['displayName']}
    Set Suite Variable  ${Capa_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${Capa_name3}  ${resp.json()[2]['displayName']}
    Set Suite Variable  ${Capa_id4}    ${resp.json()[3]['id']}
    Set Suite Variable  ${Capa_name4}  ${resp.json()[3]['displayName']}
    Set Suite Variable  ${Capa_id5}    ${resp.json()[4]['id']}
    Set Suite Variable  ${Capa_name5}  ${resp.json()[4]['displayName']}
    Set Suite Variable  ${Capa_id6}    ${resp.json()[5]['id']}
    Set Suite Variable  ${Capa_name6}  ${resp.json()[5]['displayName']}
    Set Suite Variable  ${Capa_id7}    ${resp.json()[6]['id']}
    Set Suite Variable  ${Capa_name7}  ${resp.json()[6]['displayName']}

    ${description}=    Fakerlibrary.Sentence    
    ${New_role_name1}=    Fakerlibrary.Sentence    
    ${Capabilities}=    Create List    ${Capa_id1}    
    
    ${resp}=  Create Role      ${New_role_name1}    ${description}    ${rbac_feature[0]}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${NewRole_id_1}  ${resp.json()}
    

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
            IF   not '${user_phone}' == '${HLPUSERNAME1}'
                clear_users  ${user_phone}
            END
        END
    END

     ${u_id1}=  Create Sample User 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${capabilities}=  Create List    ${Capa_id1}
    
    ${role1}=  Create Dictionary   id=${NewRole_id_1}  roleName=${New_role_name1}  defaultRole=${bool[0]}
    ...      capabilities=${Capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[1]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${NewRole_id_1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${New_role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${Capabilities}
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${NewRole_id_1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${New_role_name1}