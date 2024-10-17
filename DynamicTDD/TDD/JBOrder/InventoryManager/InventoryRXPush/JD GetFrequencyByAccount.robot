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


JD-TC-GetFrequencyByAccount-1
    [Documentation]  Get Frequency By Account

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id_PUSERNAME300}  ${resp.json()['id']}

    ${frequency0}=       Random Int  min=26  max=30
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

    ${frequency}=       Random Int  min=120  max=125
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

    ${resp}=    Get Frequency By Account  ${account_id_PUSERNAME300}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200

    ${len}=  Get Length  ${resp.json()}
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${frequency_id}'  
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${frequency_id0}'     
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id0}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency0}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description0}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark0}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos0}
        END
    END


JD-TC-GetFrequencyByAccount-2
    [Documentation]  Get Frequency By Account - where account id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=500  max=600

    ${resp}=    Get Frequency By Account  ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200

JD-TC-GetFrequencyByAccount-3
    [Documentation]  Get Frequency By Account - without login 

    ${resp}=    Get Frequency By Account  ${account_id_PUSERNAME300}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}
