*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
@{emptylist}
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${mp4file}      /ebs/TDD/MP4file.mp4
${mp3file}      /ebs/TDD/MP3file.mp3
${order}    0
${fileSize}    0.00458
${titles}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***

JD-TC-Get Prescription Templates By Filter-1

    [Documentation]    Create MedicalRecordPrescription Template then Get Prescription templates by filter

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${templateName}=  FakerLibrary.name
    Set Suite Variable    ${templateName}
    ${frequency}=  Random Int  min=500   max=1000
    Set Suite Variable    ${frequency}
    ${duration}=  Random Int  min=1   max=100
    Set Suite Variable    ${duration}
    ${instructions}=  FakerLibrary.name
    Set Suite Variable    ${instructions}
    ${dosage}=  Random Int  min=500   max=1000
    Set Suite Variable    ${dosage}
     ${medicineName}=  FakerLibrary.name
    Set Suite Variable    ${medicineName}

    ${prescription}=    Create Dictionary    frequency=${frequency}  duration=${duration}  instructions=${instructions}  dosage=${dosage}   medicineName=${medicineName} 
    Set Suite Variable    ${prescription}

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${temId}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage}

    ${resp}=    Get Prescription Templates By Filter    TemplateName-eq=${templateName} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()[0]['templateName']}     ${templateName} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['medicineName']}     ${medicineName}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['frequency']}     ${frequency}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['duration']}     ${duration}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['instructions']}     ${instructions}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['dosage']}     ${dosage}

    
JD-TC-Get Prescription Templates By Filter-2

    [Documentation]    Update MedicalRecordPrescription Template name then Get Prescription templates by filter

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${templateName0}=  FakerLibrary.name
    Set Suite Variable    ${templateName0}

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName0}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Prescription Templates By Filter    TemplateName-eq=${templateName0} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()[0]['templateName']}     ${templateName0} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['medicineName']}     ${medicineName}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['frequency']}     ${frequency}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['duration']}     ${duration}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['instructions']}     ${instructions}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['dosage']}     ${dosage}

JD-TC-Get Prescription Templates By Filter-3

    [Documentation]    Remove MedicalRecordPrescription Template  then try Get Prescription templates by filter

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Remove Prescription Template    ${temId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Prescription Templates By Filter    TemplateName-eq=${templateName0} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings   ${resp.content}   []

JD-TC-Get Prescription Templates By Filter-UH1

    [Documentation]     Get Prescription templates by filter without login

    ${resp}=    Get Prescription Templates By Filter    TemplateName-eq=${templateName0} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Prescription Templates By Filter-UH2

    [Documentation]     Get Prescription templates by filter without login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Prescription Templates By Filter    TemplateName-eq=${medicineName} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200