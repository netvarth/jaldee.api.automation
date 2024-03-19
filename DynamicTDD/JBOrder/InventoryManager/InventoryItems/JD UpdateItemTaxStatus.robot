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

JD-TC-UpdateItemTaxStatus-1

    [Documentation]  Update Item tax Status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${cgst}=     Random Int  min=0  max=200
    ${sgst}=     Random Int  min=0  max=200
    ${igst}=     Random Int  min=0  max=200
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}
    Set Suite Variable      ${igst}

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${cgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item Tax Status  ${itemtax_id}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}


JD-TC-UpdateItemTaxStatus-2

    [Documentation]  Update Item tax Status - Disable to Disable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

    ${resp}=    Update Item tax Status  ${itemtax_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateItemTaxStatus-3

    [Documentation]  Update Item tax Status - Disable to Enable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

    ${resp}=    Update Item tax Status  ${itemtax_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

JD-TC-UpdateItemTaxStatus-4

    [Documentation]  Update Item tax Status - Enable to Enable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

    ${resp}=    Update Item tax Status  ${itemtax_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemTaxStatus-5

    [Documentation]  Update Item tax Status - without login

    ${resp}=    Update Item tax Status  ${itemtax_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}