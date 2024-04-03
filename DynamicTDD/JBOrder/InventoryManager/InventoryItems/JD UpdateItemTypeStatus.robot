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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-UpdateItemTypeStatus-1

    [Documentation]  Provider Create a Item Type then try to Update Item Type Status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Item Type   ${TypeName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ty_Id}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${Ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}

JD-TC-UpdateItemTypeStatus-2

    [Documentation]  Update Item Type Status as already disabled.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${STATUS_ALREADY_UPDATED}

JD-TC-UpdateItemTypeStatus-3

    [Documentation]  try to Enable ,Disabled Status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${Ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${Ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-UpdateItemTypeStatus-UH1

    [Documentation]  Get Item Type without Login.

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemTypeStatus-UH2

    [Documentation]  Get Item Type with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 

