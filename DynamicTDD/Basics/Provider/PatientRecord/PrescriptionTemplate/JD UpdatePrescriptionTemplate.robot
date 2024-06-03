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

JD-TC-Update MedicalRecordPrescription Template-1

    [Documentation]    Update MedicalRecordPrescription Template

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${temId}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName0}=  FakerLibrary.name
    Set Suite Variable    ${templateName0}

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName0}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
     ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName0} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage}



JD-TC-Update MedicalRecordPrescription Template-2

    [Documentation]   UPdate Prescription Template where template name contain  255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  FakerLibrary.Text      max_nb_chars=255
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 


    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Update MedicalRecordPrescription Template-3

    [Documentation]   update Prescription Template where instructions contain  255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  FakerLibrary.name
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.Text      max_nb_chars=255
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

     ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Update MedicalRecordPrescription Template-4

    [Documentation]   Create MedicalRecordPrescription Template where medicine name contain  255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  FakerLibrary.name
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.Text      max_nb_chars=255
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

   ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Update MedicalRecordPrescription Template-5

    [Documentation]   update Prescription Template where template name contain  numbers

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  Random Int  min=500   max=1000
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}


JD-TC-Update MedicalRecordPrescription Template-6

    [Documentation]   update Prescription Template where empty prescription list

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  Random Int  min=500   max=1000
    Set Test Variable    ${templateName1}

    ${prescription}=    Create Dictionary     

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]}     {}


JD-TC-Update MedicalRecordPrescription Template-7

    [Documentation]   update Prescription Template where template name is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  Random Int  min=500   max=1000
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${empty}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${empty}

JD-TC-Update MedicalRecordPrescription Template-8

    [Documentation]    Update template with same details

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${prescription}=    Create Dictionary    frequency=${frequency}  duration=${duration}  instructions=${instructions}  dosage=${dosage}   medicineName=${medicineName} 

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     
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
    
     ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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


JD-TC-Update MedicalRecordPrescription Template-UH1

    [Documentation]   update Prescription Template with another provider login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  FakerLibrary.name
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.Text      max_nb_chars=255
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Update MedicalRecordPrescription Template-UH2

    [Documentation]    update Prescription Template without login
   ${templateName1}=  FakerLibrary.name
    Set Test Variable    ${templateName1}
    ${frequency1}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency1}
    ${duration1}=  Random Int  min=1   max=100
    Set Test Variable    ${duration1}
    ${instructions1}=  FakerLibrary.name
    Set Test Variable    ${instructions1}
    ${dosage1}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage1}
    ${medicineName1}=  FakerLibrary.Text      max_nb_chars=255
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

     ${resp}=    Update MedicalRecordPrescription Template   ${temId}  ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

  

   