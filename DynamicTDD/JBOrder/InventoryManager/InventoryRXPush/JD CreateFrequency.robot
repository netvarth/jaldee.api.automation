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
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/musers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
${originFrom}       NONE

*** Test Cases ***


JD-TC-CreateFrequency-1

    [Documentation]  Create Frequency

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
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
    Set Suite Variable      ${frequency0}
    Set Suite Variable      ${dosage0}
    Set Suite Variable      ${description0}
    Set Suite Variable      ${remark0}
    Set Suite Variable      ${dos0}

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
    Set Suite Variable      ${frequency}
    Set Suite Variable      ${dosage}
    Set Suite Variable      ${description}
    Set Suite Variable      ${remark}
    Set Suite Variable      ${dos}


JD-TC-CreateFrequency-2

    [Documentation]  Create Frequency - description and remark not given

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${frequency3}=       Random Int  min=1  max=10
    ${dosage3}=          Random Int  min=1  max=3000
    ${dos3}=             Evaluate    float(${dosage3})

    ${resp}=    Create Frequency  ${frequency3}  ${dosage3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id3}         ${resp.json()}

JD-TC-CreateFrequency-3

    [Documentation]  Create Frequency - where frequency is empty

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dosage3}=          Random Int  min=1  max=3000
    ${dos3}=             Evaluate    float(${dosage3})

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   Frequency

    ${resp}=    Create Frequency  ${empty}  ${dosage3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${FIELD_REQUIRED}${space}

JD-TC-CreateFrequency-4

    [Documentation]  Create Frequency - frequency is above 1000

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${frequency3}=       Random Int  min=1000  max=10000
    ${dosage3}=          Random Int  min=1  max=3000
    ${dos3}=             Evaluate    float(${dosage3})

    ${resp}=    Create Frequency  ${frequency3}  ${dosage3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id3}         ${resp.json()}

JD-TC-CreateFrequency-5

    [Documentation]  Create Frequency - Dosage is empty

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${frequency3}=       Random Int  min=1  max=10
    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   Dosage

    ${resp}=    Create Frequency  ${frequency3}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${FIELD_REQUIRED}${space}

JD-TC-CreateFrequency-6

    [Documentation]  Create Frequency - dosage is above 1000

    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${frequency3}=       Random Int  min=1  max=10
    ${dosage3}=          Random Int  min=1000  max=3000
    ${dos3}=             Evaluate    float(${dosage3})

    ${resp}=    Create Frequency  ${frequency3}  ${dosage3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id3}         ${resp.json()}

JD-TC-CreateFrequency-7

    [Documentation]  Create Frequency - without login

    ${frequency3}=       Random Int  min=1  max=10
    ${dosage3}=          Random Int  min=1  max=3000
    ${dos3}=             Evaluate    float(${dosage3})

    ${resp}=    Create Frequency  ${frequency3}  ${dosage3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}