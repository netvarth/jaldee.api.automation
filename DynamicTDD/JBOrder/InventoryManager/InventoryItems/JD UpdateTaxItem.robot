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

JD-TC-UpdateItemTax-1

    [Documentation]  Update Item tax

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
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

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${taxPercentage}=           Convert To Number  ${taxPercentage}  1
    ${cgst}=     Evaluate   ${taxPercentage} / 2
    ${sgst}=     Evaluate   ${taxPercentage} / 2
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}


    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}


JD-TC-UpdateItemTax-2

    [Documentation]  Update Item tax - tax name is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${taxName2}=    FakerLibrary.name

    ${resp}=    Update Item Tax  ${taxName2}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName2}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

JD-TC-UpdateItemTax-3

    [Documentation]  Update Item tax - tax name is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${empty}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-4

    [Documentation]  Update Item tax - tax code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${empty}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_CODE}

JD-TC-UpdateItemTax-5

    [Documentation]  Update Item tax - tax cod is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${fake}=    Random Int  min=9999    max=99999

    ${resp}=    Update Item Tax  ${taxName}  ${fake}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_CODE}

JD-TC-UpdateItemTax-6

    [Documentation]  Update Item tax - type enum is changed 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[1]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[1]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}


JD-TC-UpdateItemTax-8

    [Documentation]  Update Item tax - tax percentage is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${taxPercentage2}=     Random Int  min=0  max=200    

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage2}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

JD-TC-UpdateItemTax-9

    [Documentation]  Update Item tax - tax percentage is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${empty}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_PERCENTAGE}

JD-TC-UpdateItemTax-10

    [Documentation]  Update Item tax - cgst is changes

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cgst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst2}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-11

    [Documentation]  Update Item tax - cgst is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${empty}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_CGST_PERCENTAGE}

JD-TC-UpdateItemTax-12

    [Documentation]  Update Item tax - sgst is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sgst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-13

    [Documentation]  Update Item tax - sgst is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${empty}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_SGST_PERCENTAGE}

JD-TC-UpdateItemTax-14

    [Documentation]  Update Item tax - igst is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${igst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-15

    [Documentation]  Update Item tax - igst is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_IGST_PERCENTAGE}

JD-TC-UpdateItemTax-16

    [Documentation]  Update Item tax - without login

    ${resp}=    Update Item Tax  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}

JD-TC-UpdateItemTax-17

    [Documentation]  Update Item tax - with another provider login wo dont have created tax

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

    ${taxName2}=    FakerLibrary.name

    ${resp}=    Update Item Tax  ${taxName2}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName2}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}