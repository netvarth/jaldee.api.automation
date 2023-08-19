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
${roleName1}    Role Name 1
${roleName2}    Role Name 2
*** Test Cases ***

JD-TC-RestoreRolesById-1

    [Documentation]  Create  Roles with empty Capabilities and update role then disable the role then restore the role by id.

    ${resp}=  Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role       ${roleName1}    ${description}    ${featureName}    ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()[0]['id']}


    # ${resp}=  Get roles by id    ${id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${description2}=    Fakerlibrary.Sentence    
    # ${featureName2}=    FakerLibrary.name    

    # ${resp}=  Update Role   ${id}     Hisham    ${description2}    ${featureName2}    ${emptylist}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get roles by id    ${id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    # Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    # Should Be Equal As Strings  ${resp.json()['roleName']}  Hisham

    # ${resp}=  Update role status    ${id}    ${toggle[1]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[1]}
    # Set Test Variable  ${roleid}  ${resp.json()['roleId']}

    ${resp}=  Restore role by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-RestoreRolesById-2

    [Documentation]   Create two Roles with  Capabilities and restore only 1 role by id.

    ${resp}=  Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    # ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
    # Log  ${resp1.content}
    # Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableRbac']}  ${bool[1]}

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Suite Variable  ${capability1}  ${resp.json()[3]['capabilityList']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}
    Set Suite Variable  ${cap1}  ${resp.json()[3]['capabilityList'][2]}
    Set Suite Variable  ${cap2}  ${resp.json()[5]['capabilityList'][6]}
    Set Suite Variable  ${cap3}  ${resp.json()[5]['capabilityList'][4]}
    Set Suite Variable  ${cap4}  ${resp.json()[2]['capabilityList'][3]}


    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${Capabilities}=    Create List    ${cap1}    ${cap3}

    ${resp}=  Create Role       ${roleName2}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()[0]['id']}
    Set Test Variable  ${roleid}  ${resp.json()[0]['roleId']}
    ${len}=  Get Length  ${resp.json()}

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${Capabilities}=    Create List    ${cap2}    ${cap4}

    ${resp}=  Create Role       ${roleName1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()[7]['id']}
    Set Test Variable  ${roleid1}  ${resp.json()[7]['roleId']}
    Set Test Variable  ${id2}  ${resp.json()[8]['id']}
    Set Test Variable  ${roleid2}  ${resp.json()[8]['roleId']}
    ${len}=  Get Length  ${resp.json()}

    # ${resp}=  Get roles
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length  ${resp.json()}

    ${resp}=  Restore role by id    ${id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Restore role by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}