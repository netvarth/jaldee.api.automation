*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM GROUP
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Test Cases ***


JD-TC-CreateItemGroup-1

    [Documentation]  Create Item Group for an existing provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroup-2

    [Documentation]  Create multiple Item Group for an existing provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroup-3

    [Documentation]  Create multiple Item Group with same name for an existing provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateItemGroup-4

    [Documentation]  Create Item Group with group name as numbers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   Random Int   min=1000000   max=5000000
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateItemGroup-5

    [Documentation]  Create Item Group for a provider without group decscription.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}
    
    ${groupName}=    FakerLibrary.word
    ${resp}=  Create Item Group   ${groupName}  ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateItemGroup-UH1

    [Documentation]  Create Item Group for a provider without enable item group flag in account settings.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422


JD-TC-CreateItemGroup-UH2

    [Documentation]  Create Item Group for a provider without group name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}
    
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${EMPTY}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"   "${ITEM_GROUP_NAME_IS_MUST}" 

JD-TC-CreateItemGroup-UH3

    [Documentation]  create item group without login

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-CreateItemGroup-UH4

    [Documentation]  Consumer try to create an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
