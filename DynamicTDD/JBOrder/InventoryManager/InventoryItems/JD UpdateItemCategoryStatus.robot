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

JD-TC-UpdateItemCategoryStatus-1

    [Documentation]  Provider Create a Item Category then try to Update Item Category Status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}

JD-TC-UpdateItemCategoryStatus-2

    [Documentation]  Update Item Category Status as already disabled.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}

JD-TC-UpdateItemCategoryStatus-3

    [Documentation]  try to Enable ,Disabled Status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-UpdateItemCategoryStatus-UH1

    [Documentation]  Get Item Category without Login.

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemCategoryStatus-UH2

    [Documentation]  Get Item Category with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 

