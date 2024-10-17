*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PURCHASE 
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
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
${originFrom}       NONE

*** Test Cases ***


JD-TC-UpdateFrequencyStatus-1
    [Documentation]  Update Frequency Status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${frequency}=       Random Int  min=11  max=20
    ${dosage}=          Random Int  min=1  max=3000
    ${description}=     FakerLibrary.sentence
    ${remark}=          FakerLibrary.sentence
    ${dos}=             Evaluate    float(${dosage})

    ${resp}=    Create Frequency  ${frequency}  ${dosage}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[1]}

    ${resp}=    Update Frequency Status  ${frequency_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[0]}

JD-TC-UpdateFrequencyStatus-UH1
    [Documentation]  Update Frequency Status - status disable to disable

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[0]}

    ${resp}=    Update Frequency Status  ${frequency_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        422
    Should Be Equal As Strings      ${resp.json()}             ${RECORD_ALREADY_UPDATED}

JD-TC-UpdateFrequencyStatus-U2
    [Documentation]  Update Frequency Status - status disable to enable

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[0]}

    ${resp}=    Update Frequency Status  ${frequency_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[1]}

JD-TC-UpdateFrequencyStatus-UH2
    [Documentation]  Update Frequency Status - status enable to enable

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['active']}        ${bool[1]}

    ${resp}=    Update Frequency Status  ${frequency_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        422
    Should Be Equal As Strings      ${resp.json()}             ${RECORD_ALREADY_UPDATED}

JD-TC-UpdateFrequencyStatus-UH3
    [Documentation]  Update Frequency Status - without login

    ${resp}=    Update Frequency Status  ${frequency_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        419
    Should Be Equal As Strings      ${resp.json()}             ${SESSION_EXPIRED}