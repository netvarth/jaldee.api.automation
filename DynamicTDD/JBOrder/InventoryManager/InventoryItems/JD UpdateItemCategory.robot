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

JD-TC-UpdateItemCategory-1

    [Documentation]  Provider Create a Item Category then try to Update that item name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
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

    ${categoryName1}=    FakerLibrary.name
    Set Suite Variable  ${categoryName1}


    ${resp}=  Update Item Category   ${categoryName1}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}


JD-TC-UpdateItemCategory-2

    [Documentation]  Update item CategoryName to a Number.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.Random Number

    ${resp}=  Update Item Category   ${Name1}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${Name1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-UpdateItemCategory-3

    [Documentation]  Update item CategoryName then update it's Item Category Status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.name

    ${resp}=  Update Item Category   ${Name}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}   

    ${resp}=  Update Item Category Status   ${Ca_Id}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]} 

JD-TC-UpdateItemCategory-4

    [Documentation]  Try to Update Disable item  .

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.name

    ${resp}=  Update Item Category   ${Name}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]} 

JD-TC-UpdateItemCategory-5

    [Documentation]  Update item Category name as same.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Category   ${categoryName1}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemCategory-6

    [Documentation]  Update item CategoryName With EMPTY value.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${Name1}=    FakerLibrary.Random Number

    ${resp}=  Update Item Category   ${EMPTY}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemCategory-UH1

    [Documentation]  Get Item Category without Login.

    ${resp}=  Update Item Category   ${EMPTY}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemCategory-UH2

    [Documentation]  Get Item Category with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Item Category   ${EMPTY}    ${Ca_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
