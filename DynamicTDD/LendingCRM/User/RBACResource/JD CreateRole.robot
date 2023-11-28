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

JD-TC-CreateRole-1

    [Documentation]  Create  Roles for an existing provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME48}  ${PASSWORD}
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

    ${description}=    Fakerlibrary.Sentence    
    ${featureName}=    FakerLibrary.name    

    ${resp}=  Create Role      ${role_name1}    ${description}    ${featureName}    ${emptylist}
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

    ${resp}=  Update Role   ${id}    ${role_name1}    ${description2}    ${featureName2}    ${emptylist}
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

    ${resp}=  Restore roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[1]}

JD-TC-CreateRole-2

    [Documentation]  Create  Roles with id  zero.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${featureName1}=    FakerLibrary.name    

    ${resp}=  Create Role      ${role_name1}    ${description1}    ${featureName1}   ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()[1]['id']}

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=    Fakerlibrary.Sentence    
    ${featureName2}=    FakerLibrary.name    

    ${resp}=  Update Role   ${id2}     ${role_name1}    ${description2}    ${featureName2}  ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['description']}  ${description2}
    Should Be Equal As Strings  ${resp.json()['featureName']}  ${featureName2}
    Should Be Equal As Strings  ${resp.json()['roleName']}  ${role_name1}

    ${resp}=  Restore role by id    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles by id    ${id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['status']}  ${toggle[0]}

JD-TC-CreateRole-3

    [Documentation]  Create  Roles with id  3.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description1}=    Fakerlibrary.Sentence    
    ${featureName1}=    FakerLibrary.name    

    ${resp}=  Create Role    ${role_name1}    ${description1}    ${featureName1}    ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()[2]['id']}

    ${resp}=  Get roles by id    ${id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateRole-UH1

    [Documentation]   Enable Rbac without login

    ${description1}=    Fakerlibrary.Sentence    
    ${featureName1}=    FakerLibrary.name    

    ${resp}=  Create Role        ${role_name1}    ${description1}    ${featureName1}    ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateRole-UH2

    [Documentation]   Enable Rbac Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description1}=    Fakerlibrary.Sentence    
    ${featureName1}=    FakerLibrary.name    

    ${resp}=  Create Role       ${role_name1}    ${description1}    ${featureName1}     ${emptylist}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}