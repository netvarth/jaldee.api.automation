*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetItemType-1

    [Documentation]  Provider Create a Item Type then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Item Type   ${TypeName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ty_Id}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemType-2

    [Documentation]  Provider Create another Item Type then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Item Type   ${TypeName1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ty_Id1}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id1}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemType-3

    [Documentation]  Provider Create another Item Type with number then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${TypeName2}=    FakerLibrary.Random Number
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Item Type   ${TypeName2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ty_Id2}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id2}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName2}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemCategory-UH1

    [Documentation]  Get Item Category without Login.

    # ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Get Item Category   ${Ty_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemCategory-UH2

    [Documentation]  Get Item Category with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Get Item Category   ${Ty_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 

