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

JD-TC-CreateItemTax-1

    [Documentation]  Get Item tax Filter

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

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['taxCode']}            ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()[0]['taxName']}            ${taxName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}             ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['taxTypeEnum']}        ${taxtypeenum[0]}

JD-TC-CreateItemTax-2

    [Documentation]  Get Item tax Filter - taxCode filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax Filter   taxCode-eq=${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['taxCode']}            ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()[0]['taxName']}            ${taxName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}             ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['taxTypeEnum']}        ${taxtypeenum[0]}

JD-TC-CreateItemTax-3

    [Documentation]  Get Item tax Filter - taxName filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax Filter   taxName-eq=${taxName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['taxCode']}            ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()[0]['taxName']}            ${taxName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}             ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['taxTypeEnum']}        ${taxtypeenum[0]}

JD-TC-CreateItemTax-4

    [Documentation]  Get Item tax Filter - status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax Filter   status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-CreateItemTax-UH1

    [Documentation]  Get Item tax Filter - without login

    ${resp}=    Get Item Tax Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}

JD-TC-CreateItemTax-UH2

    [Documentation]  Get Item tax Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['taxCode']}            ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()[0]['taxName']}            ${taxName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}             ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['taxTypeEnum']}        ${taxtypeenum[0]}
    