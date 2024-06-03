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

JD-TC-GetItemHsnFilter-1

    [Documentation]  Get Item Hsn Filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id}       ${decrypted_data['id']}
    Set Suite Variable  ${userName}     ${decrypted_data['userName']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${hsnCode}=     Random Int  min=1  max=9999
    Set Suite Variable      ${hsnCode}

    ${resp}=    Create Item hns  ${hsnCode} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${hns_id}   ${resp.json()}

    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

    ${hsnCode2}=     Random Int  min=1  max=9999
    Set Suite Variable      ${hsnCode2}

    ${resp}=    Create Item hns  ${hsnCode2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${hns_id2}   ${resp.json()}

    ${resp}=    Get Item hns by id   ${hns_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

    ${resp}=    Get Item hns Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()[0]['hsnCode']}        ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}      ${acc_id} 
    Should Be Equal As Strings    ${resp.json()[0]['createdByName']}  ${userName}
    Should Be Equal As Strings    ${resp.json()[1]['hsnCode']}        ${hsnCode}
    Should Be Equal As Strings    ${resp.json()[1]['createdBy']}      ${acc_id} 
    Should Be Equal As Strings    ${resp.json()[1]['createdByName']}  ${userName}


JD-TC-GetItemHsnFilter-2

    [Documentation]  Get Item hns Filter - hsnCode

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item hns Filter    hsnCode-eq=${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()[0]['hsnCode']}        ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}      ${acc_id} 
    Should Be Equal As Strings    ${resp.json()[0]['createdByName']}  ${userName}



JD-TC-GetItemHsnFilter-4

    [Documentation]  Get Item hns Filter - status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item hns Filter    status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()[0]['hsnCode']}        ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}      ${acc_id} 
    Should Be Equal As Strings    ${resp.json()[0]['createdByName']}  ${userName}
    Should Be Equal As Strings    ${resp.json()[1]['hsnCode']}        ${hsnCode}
    Should Be Equal As Strings    ${resp.json()[1]['createdBy']}      ${acc_id} 
    Should Be Equal As Strings    ${resp.json()[1]['createdByName']}  ${userName}

JD-TC-GetItemHsnFilter-UH1

    [Documentation]  Get Item hns Filter - without login

    ${resp}=    Get Item hns Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-GetItemHsnFilter-5

    [Documentation]  Get Item hns Filter - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item hns Filter 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}         200
    Should Be Equal As Strings    ${resp.json()}    []