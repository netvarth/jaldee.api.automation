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

JD-TC-AppendTeamScope-1

    [Documentation]  Create User With Roles And Scope then update his manager.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    
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
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

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
            IF   not '${user_phone}' == '${MUSERNAME132}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id1}=  Create Sample User 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User 
    Set Suite Variable  ${u_id2}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME2}  ${resp.json()['mobileNo']}

    ${u_id3}=  Create Sample User 
    Set Suite Variable  ${u_id3}

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME3}  ${resp.json()['mobileNo']}

    ${team_name2}=  FakerLibrary.name
    ${team_size2}=  Random Int  min=10  max=50
    ${desc2}=   FakerLibrary.sentence
    ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${team1}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id1}  ${u_id2}
    ${resp}=   Assign Team To User  ${user_ids}  ${team1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Teams
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary    id=${role_id1}   roleName=${role_name1}   defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${team_ids}=  Create List   ${team1}  

    ${resp}=  Append Team Scope  ${rbac_feature[0]}  ${team_ids}  ${user_roles} 
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

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Team Scope By Id  ${u_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Scope By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}       ${role_id1}
    Should Be Equal As Strings  ${resp.json()[0]['roleName']}     ${role_name1}
    Should Be Equal As Strings  ${resp.json()[0]['defaultRole']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['capabilities']}   ${capability1}

    