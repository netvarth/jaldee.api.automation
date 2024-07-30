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


JD-TC-GetItemGroup-1

    [Documentation]  Create Item Group for an existing provider and get the details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
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

    ${groupName1}=    FakerLibrary.word
    Set Suite Variable    ${groupName1}
    ${groupDesc1}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc1}
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc1}

JD-TC-GetItemGroup-2

    [Documentation]  Create multiple Item Group for an existing provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName2}=    FakerLibrary.word
    ${groupDesc2}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()[1]['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()[1]['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()[1]['groupDesc']}    ${groupDesc2}

JD-TC-GetItemGroup-3

    [Documentation]  Create multiple Item Group with same name for an existing provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME138}  ${PASSWORD}
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
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc}

    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc}

    Should Be Equal As Strings  ${resp.json()[1]['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()[1]['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()[1]['groupDesc']}    ${groupDesc}

JD-TC-GetItemGroup-4

    [Documentation]  Create Item Group for a provider without group decscription.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME119}  ${PASSWORD}
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
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${EMPTY}


JD-TC-GetItemGroup-5

    [Documentation]  Get Item Group without creating item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}    []


JD-TC-GetItemGroup-UH1

    [Documentation]  Get item group without login

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-GetItemGroup-UH2

    [Documentation]  Consumer try to Get an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
