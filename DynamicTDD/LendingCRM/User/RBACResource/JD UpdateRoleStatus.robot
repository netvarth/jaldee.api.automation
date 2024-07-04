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

*** Test Cases ***
JD-TC-UpdateRoleStatus-1

    [Documentation]  Create  Roles and  Update role status as Disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
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

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['roleId']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${cap1}  ${resp.json()[3]['capabilityList'][2]}
    Set Suite Variable  ${cap2}  ${resp.json()[5]['capabilityList'][5]}
    Set Suite Variable  ${cap3}  ${resp.json()[5]['capabilityList'][3]}
    Set Suite Variable  ${cap4}  ${resp.json()[2]['capabilityList'][4]}

    # ${resp}=  Get roles
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length  ${resp.json()}
    # Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}
    # Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}
    # Set Suite Variable  ${cap1}  ${resp.json()[3]['capabilityList'][2]}
    # Set Suite Variable  ${cap2}  ${resp.json()[5]['capabilityList'][6]}
    # Set Suite Variable  ${cap3}  ${resp.json()[5]['capabilityList'][4]}
    # Set Suite Variable  ${cap4}  ${resp.json()[2]['capabilityList'][3]}

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    
    ${Capabilities}=    Create List    ${cap1}    ${cap2}
    Set Suite Variable  ${Capabilities}

    ${resp}=  Create Role     ${role_name1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    # ${resp}=  Get roles
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${id}  ${resp.json()[0]['id']}


    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id}     ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}

    ${resp}=  Update role status    ${id}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[1]}

JD-TC-UpdateRoleStatus-2

    [Documentation]  Update role status to Enable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update role status    ${id}    ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}

JD-TC-UpdateRoleStatus-UH1

    [Documentation]   Update role status without login

    ${resp}=  Update role status    ${id}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateRoleStatus-UH2

    [Documentation]   Update role status Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update role status    ${id}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateRoleStatus-UH3

    [Documentation]    Update role status enable two times.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role     ${role_name1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id1}  ${resp.json()}

    ${resp}=  Update role status    ${id1}    ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${ALREADY_ENABLED}

JD-TC-UpdateRoleStatus-UH4

    [Documentation]    Disable role status which is already disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update role status    ${id1}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[1]}

    ${resp}=  Update role status    ${id1}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${ALREADY_DISABLED}