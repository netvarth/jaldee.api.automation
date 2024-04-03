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

JD-TC-UpdateItemHsn-1

    [Documentation]  Update Item Hsn - Hsn Code changed

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id}       ${decrypted_data['id']}
    Set Suite Variable  ${userName}     ${decrypted_data['userName']}

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

    ${resp}=    Update Item hns  ${hns_id}  ${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200

    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

JD-TC-UpdateItemHsn-UH1

    [Documentation]  Update Item Hsn - Hsn Code is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item hns  ${hns_id}   ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200

JD-TC-UpdateItemHsn-UH2

    [Documentation]  Update Item Hsn - Hsn Id is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   HsnCode code

    ${resp}=    Update Item hns  ${empty}   ${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}          ${INVALID_FIELD}

JD-TC-UpdateItemHsn-UH3

    [Documentation]  Update Item Hsn - hsn id is invalid changed

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   HsnCode code

    ${resp}=    Update Item hns  ${inv}   ${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}          ${INVALID_FIELD}

JD-TC-UpdateItemHsn-UH4

    [Documentation]  Update Item Hsn - without login

    ${resp}=    Update Item hns  ${hns_id}   ${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}          ${SESSION_EXPIRED}

JD-TC-UpdateItemHsn-UH5

    [Documentation]  Update Item Hsn - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Item hns  ${hns_id}   ${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}          ${NO_PERMISSION}