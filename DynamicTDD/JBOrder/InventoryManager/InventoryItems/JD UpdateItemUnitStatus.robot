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

JD-TC-UpdateItemUnitStatus-1

    [Documentation]  Update Item Unit Status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${unitName}=          FakerLibrary.name
    ${convertionQty}=     Random Int  min=0  max=200
    Set Suite Variable      ${unitName}
    Set Suite Variable      ${convertionQty}

    ${resp}=    Create Item Unit  ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${iu_id}  ${resp.json()}

    ${resp}=    Get Item Unit by id  ${iu_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

    ${resp}=    Update Item Unit Status  ${iu_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit by id  ${iu_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['unitCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[1]}


JD-TC-UpdateItemUnitStatus-2

    [Documentation]  Update Item Unit Status as already disabled.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Unit Status   ${iu_id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Unit by id   ${iu_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}

JD-TC-UpdateItemUnitStatus-3

    [Documentation]  try to Enable ,Disabled Status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Unit Status   ${iu_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Unit by id   ${iu_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-UpdateItemUnitStatus-UH1

    [Documentation]  Get Item Unit without Login.

    ${resp}=  Update Item Unit Status   ${iu_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemUnitStatus-UH2

    [Documentation]  Get Item Unit with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Item Unit Status   ${iu_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 