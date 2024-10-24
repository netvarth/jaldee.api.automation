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


JD-TC-GetFrequency-1
    [Documentation]  Get Frequency

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${frequency0}=       Random Int  min=100  max=105
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

JD-TC-GetFrequency-2
    [Documentation]  Get Frequency - where frequency id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Get Frequency  ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Empty  ${resp.content}
    
JD-TC-GetFrequency-3
    [Documentation]  Get Frequency - without login

    ${resp}=    Get Frequency  ${frequency_id0}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}