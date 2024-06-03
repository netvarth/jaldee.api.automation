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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
*** Test Cases ***

JD-TC-UpdateFrequencySA-1

    [Documentation]   Update Frequency SA

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    SA Create Frequency  ${frequency}  ${dosage}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id}         ${resp.json()}

    ${resp}=    SA Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

    ${frequency2}=       Random Int  min=1  max=10

    ${resp}=    SA Update Frequency  ${frequency_id}  ${frequency2}  ${dosage}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    SA Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency2}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

JD-TC-UpdateFrequencySA-2

    [Documentation]   Update Frequency SA - updated dosage

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dosage2}=          Random Int  min=1  max=3000
    ${dos2}=             Evaluate    float(${dosage2})

    ${resp}=    SA Update Frequency  ${frequency_id}  ${frequency2}  ${dosage2}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    SA Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos2}