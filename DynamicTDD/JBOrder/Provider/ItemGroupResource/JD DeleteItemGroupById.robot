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


JD-TC-DeleteItemGroupById-1

    [Documentation]  Create Item Group for an existing provider and get the details then delete item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
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

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}

    ${resp}=  Delete Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    []

JD-TC-DeleteItemGroupById-2

    [Documentation]  Create multiple Item Group for an existing provider then delete one group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
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

    ${groupName2}=    FakerLibrary.word
    ${groupDesc2}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group By Id   ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}

    ${groupName3}=    FakerLibrary.word
    ${groupDesc3}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName3}  ${groupDesc3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id3}  ${resp.json()}

    ${resp}=  Get Item Group By Id   ${item_group_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id3}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName3}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc3}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()[1]['itemGroupId']}  ${item_group_id3}
    Should Be Equal As Strings  ${resp.json()[1]['groupName']}    ${groupName3}
    Should Be Equal As Strings  ${resp.json()[1]['groupDesc']}    ${groupDesc3}

    ${resp}=  Delete Item Group By Id  ${item_group_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc2}

JD-TC-DeleteItemGroupById-UH1

    [Documentation]  Get Item Group with invalid item group id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
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
    
    ${itemgroupid}=   Random Int   min=1000000   max=5000000
    ${resp}=  Delete Item Group By Id   ${itemgroupid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422


JD-TC-DeleteItemGroupById-UH2

    [Documentation]  Get item group without login

    ${resp}=  Delete Item Group By Id   ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-DeleteItemGroupById-UH3

    [Documentation]  Consumer try to Get an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Item Group By Id   ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

