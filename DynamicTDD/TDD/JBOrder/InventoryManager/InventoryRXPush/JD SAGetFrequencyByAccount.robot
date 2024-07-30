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


JD-TC-GetAllAccountFrequency-1

    [Documentation]  Get All Account Frequency

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${frequency}=       Random Int  min=150  max=155
    ${dosage}=          Random Int  min=1  max=3000
    ${description}=     FakerLibrary.sentence
    ${remark}=          FakerLibrary.sentence
    ${dos}=             Evaluate    float(${dosage})
    Set Suite Variable      ${frequency}
    Set Suite Variable      ${dosage}
    Set Suite Variable      ${description}
    Set Suite Variable      ${remark}
    Set Suite Variable      ${dos}

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

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

#   -----------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id2}  ${resp.json()['id']}

    ${frequency2}=       Random Int  min=170  max=175
    ${dosage2}=          Random Int  min=1  max=3000
    ${description2}=     FakerLibrary.sentence
    ${remark2}=          FakerLibrary.sentence
    ${dos2}=             Evaluate    float(${dosage2})
    Set Suite Variable      ${frequency2}
    Set Suite Variable      ${dosage2}
    Set Suite Variable      ${description2}
    Set Suite Variable      ${remark2}
    Set Suite Variable      ${dos2}

    ${resp}=    Create Frequency  ${frequency2}  ${dosage2}  description=${description2}  remark=${remark2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id2}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id2}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency2}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description2}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark2}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos2}

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    SA Get Frequency By Account  0
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200


    ${len}=  Get Length  ${resp.json()}
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${frequency_id2}'  
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id2}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency2}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description2}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark2}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos2}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${frequency_id}'     
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos}
        END
    END


JD-TC-GetAllAccountFrequency-2

    [Documentation]  Get Frequency by account 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    SA Get Frequency By Account  ${account_id2}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200


    ${len}=  Get Length  ${resp.json()}
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${frequency_id2}'  
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id2}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency2}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description2}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark2}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos2}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${frequency_id}'     
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos}
        END
    END
