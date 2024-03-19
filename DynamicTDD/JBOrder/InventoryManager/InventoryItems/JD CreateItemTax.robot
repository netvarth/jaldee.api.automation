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

    [Documentation]  Create Item tax

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

JD-TC-CreateItemTax-UH1

    [Documentation]  Create Item tax - where tax name is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${empty}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-CreateItemTax-2

    [Documentation]  Create Item tax - where tax type enum is vat ( For VAT and CDSS CGST,SGST and IGST are not Mandatory)

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${taxName2}=    FakerLibrary.name

    ${resp}=    Create Item Tax  ${taxName2}  ${taxtypeenum[2]}  ${taxPercentage}  ${empty}  ${empty}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemTax-3

    [Documentation]  Create Item tax - where tax type enum is CESS ( For VAT and CDSS CGST,SGST and IGST are not Mandatory)

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${taxName3}=    FakerLibrary.name

    ${resp}=    Create Item Tax  ${taxName3}  ${taxtypeenum[1]}  ${taxPercentage}  ${empty}  ${empty}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemTax-UH3

    [Documentation]  Create Item tax - tax percentage is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${empty}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_PERCENTAGE}

JD-TC-CreateItemTax-UH4

    [Documentation]  Create Item tax - cgst is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${empty}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_CGST_PERCENTAGE}

JD-TC-CreateItemTax-UH5

    [Documentation]  Create Item tax - sgst is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${empty}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_SGST_PERCENTAGE}

JD-TC-CreateItemTax-UH6

    [Documentation]  Create Item tax - igst is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_IGST_PERCENTAGE}

JD-TC-CreateItemTax-UH7 

    [Documentation]  Create Item tax - without Login

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${cgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}


JD-TC-CreateItemTax-UH8

    [Documentation]  Create Item tax - consumer login

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}         ${NoAccess}

JD-TC-CreateItemTax-UH9

    [Documentation]  Create Item tax - creating a tax with existing name

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422