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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***
JD-TC-UpdateRole-1

    [Documentation]  Update  Roles with default role id (0).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}    ${resp.json()[0]['roleId']}
    Set Suite Variable  ${role_name1}  ${resp.json()[0]['displayName']}
    Set Suite Variable  ${cap1}  ${resp.json()[3]['capabilityList'][2]}
    Set Suite Variable  ${cap2}  ${resp.json()[5]['capabilityList'][6]}
    Set Suite Variable  ${cap3}  ${resp.json()[5]['capabilityList'][4]}
    Set Suite Variable  ${cap4}  ${resp.json()[2]['capabilityList'][3]}

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    
    ${Capabilities}=    Create List    ${cap1}    ${cap2}
    Set Suite Variable  ${Capabilities}

    ${resp}=  Create Role       ${role_name1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()[0]['id']}


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

JD-TC-UpdateRole-2

    [Documentation]  Update  Roles with default role id to 1.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role      ${role_name1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()[1]['id']}


    ${resp}=  Get roles by id    ${id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id1}     ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}

JD-TC-UpdateRole-3

    [Documentation]  Update  Roles with  role id 6 to 1.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role     ${role_name1}    ${description}    ${featureName}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()[2]['id']}


    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=    Fakerlibrary.Sentence 
    Set Suite Variable  ${description2}    
    ${featureName2}=    FakerLibrary.name    
    Set Suite Variable  ${featureName2}    

    ${resp}=  Update Role   ${id2}       ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}

JD-TC-UpdateRole-4

    [Documentation]  Update same Roles two times.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Update Role   ${id2}      ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}

JD-TC-UpdateRole-UH1

    [Documentation]   Update Role without login

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}       ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateRole-UH2

    [Documentation]   Update Role Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}       ${role_name1}    ${description2}    ${featureName2}    ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateRole-UH3

    [Documentation]  Update Roles with invalid  id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    
    ${invalid_id}=  Random Int  min=20   max=40
    ${resp}=  Update Role   ${invalid_id}      ${role_name1}    ${description2}    ${featureName2}     ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${ENTER_VALID_ROLE_ID}

JD-TC-UpdateRole-UH4

    [Documentation]  Update Roles with empty role_name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}     ${EMPTY}    ${description2}    ${featureName2}     ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateRole-UH5

    [Documentation]  Update Roles with empty description.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}      ${role_name1}    ${EMPTY}    ${featureName2}     ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateRole-UH6

    [Documentation]  Update Roles with empty featureName.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}       ${role_name1}    ${description2}    ${EMPTY}     ${Capabilities}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200