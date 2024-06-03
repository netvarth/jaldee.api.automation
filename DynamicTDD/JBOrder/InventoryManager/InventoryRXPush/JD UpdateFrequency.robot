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


JD-TC-UpdateFrequency-1

    [Documentation]  Update Frequency - frequency updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${frequency0}=       Random Int  min=1  max=10
    ${dosage0}=          Random Int  min=1  max=3000
    ${description0}=     FakerLibrary.sentence
    ${remark0}=          FakerLibrary.sentence
    ${dos0}=             Evaluate    float(${dosage0})

    ${resp}=    Create Frequency  ${frequency0}  ${dosage0}  description=${description0}  remark=${remark0}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id0}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id0}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id0}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency0}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description0}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark0}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos0}

    ${frequency}=       Random Int  min=1  max=10
    ${dosage}=          Random Int  min=1  max=3000
    ${description}=     FakerLibrary.sentence
    ${remark}=          FakerLibrary.sentence
    ${dos}=             Evaluate    float(${dosage})
    Set Suite Variable  ${frequency}
    Set Suite Variable  ${dos}
    Set Suite Variable  ${description}
    Set Suite Variable  ${remark}

    ${resp}=    Create Frequency  ${frequency}  ${dos}  description=${description}  remark=${remark}
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

    ${frequency2}=       Random Int  min=1  max=10
    
    ${resp}=    Update Frequency  ${frequency_id}  ${frequency2}  ${dos}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency2}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequency-2

    [Documentation]  Update Frequency - dosage is updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dosage2}=          Random Int  min=1  max=3000
    ${dos2}=             Evaluate    float(${dosage2})

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos2}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos2}

JD-TC-UpdateFrequency-3

    [Documentation]  Update Frequency - description is updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=     FakerLibrary.sentence

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos}  description=${description2}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description2}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequency-4

    [Documentation]  Update Frequency - remark is updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark2}=     FakerLibrary.sentence

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos}  description=${description}  remark=${remark2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark2}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequency-5

    [Documentation]  Update Frequency - remarks is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos}  description=${description}  remark=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${empty}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequency-6

    [Documentation]  Update Frequency - description is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos}  description=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${empty}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${empty}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequency-7

    [Documentation]  Update Frequency - dosage is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   Dosage

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${empty}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${FIELD_REQUIRED}${space}

JD-TC-UpdateFrequency-8

    [Documentation]  Update Frequency - frequency is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   Frequency

    ${resp}=    Update Frequency  ${frequency_id}  ${empty}  ${dos}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${FIELD_REQUIRED}${space}

JD-TC-UpdateFrequency-9

    [Documentation]  Update Frequency - frequency id is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_X_ID}=    format String   ${INVALID_X_ID}   Frequency

    ${resp}=    Update Frequency  ${empty}  ${frequency}  ${dos}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_X_ID}

JD-TC-UpdateFrequency-10

    [Documentation]  Update Frequency - frequency id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=90  max=99

    ${INVALID_X_ID}=    format String   ${INVALID_X_ID}   Frequency

    ${resp}=    Update Frequency  ${inv}  ${frequency}  ${dos}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_X_ID}

JD-TC-UpdateFrequency-11

    [Documentation]  Update Frequency - without login

    ${resp}=    Update Frequency  ${frequency_id}  ${frequency}  ${dos}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}