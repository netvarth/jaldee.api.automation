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

JD-TC-GetItemHsn-1

    [Documentation]  Get Item Hsn

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id}       ${decrypted_data['id']}
    Set Suite Variable  ${userName}     ${decrypted_data['userName']}

    ${hsnCode}=     Random Int  min=1  max=9999

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


JD-TC-GetItemHsn-UH1

    [Documentation]  Get Item Hsn - where hsn code is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=-999  max=9999

    ${resp}=    Get Item hns by id   ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Empty     ${resp.content}

JD-TC-GetItemHsn-UH2

    [Documentation]  Get Item Hsn - without login

    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-GetItemHsn-UH3

    [Documentation]  Get Item Hsn - with another provider login

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     
    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION}