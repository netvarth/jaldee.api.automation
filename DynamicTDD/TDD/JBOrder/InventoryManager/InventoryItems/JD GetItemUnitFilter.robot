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
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetitemUitFilter-1

    [Documentation]  Get Item Unit Filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
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
    
    ${unitName2}=          FakerLibrary.name
    ${convertionQty2}=     Random Int  min=0  max=200
    Set Suite Variable      ${unitName2}
    Set Suite Variable      ${convertionQty2}

    ${resp}=    Create Item Unit  ${unitName2}  ${convertionQty2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${iu_id2}  ${resp.json()}

    ${resp}=    Get Item Unit by id  ${iu_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${iu_id2}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

    Should Be Equal As Strings    ${resp.json()[1]['unitCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()[1]['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()[1]['status']}      ${toggle[0]}

JD-TC-GetitemUitFilter-2

    [Documentation]  Get Item Unit Filter - unitCode    

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter    unitCode-eq=${iu_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${iu_id2}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

JD-TC-GetitemUitFilter-3

    [Documentation]  Get Item Unit Filter - unitName

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter    unitName-eq=${unitName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${iu_id2}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

JD-TC-GetitemUitFilter-4

    [Documentation]  Get Item Unit Filter - status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter    status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['unitCode']}    ${iu_id2}
    Should Be Equal As Strings    ${resp.json()[0]['unitName']}    ${unitName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}      ${toggle[0]}

    Should Be Equal As Strings    ${resp.json()[1]['unitCode']}    ${iu_id}
    Should Be Equal As Strings    ${resp.json()[1]['unitName']}    ${unitName}
    Should Be Equal As Strings    ${resp.json()[1]['status']}      ${toggle[0]}

JD-TC-GetitemUitFilter-UH1

    [Documentation]  Get Item Unit Filter - withou login

    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-GetitemUitFilter-UH2

    [Documentation]  Get Item Unit Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Unit Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}         []