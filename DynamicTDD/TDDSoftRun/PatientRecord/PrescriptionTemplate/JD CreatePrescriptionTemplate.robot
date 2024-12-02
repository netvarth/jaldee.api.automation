*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py
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

JD-TC-Create Treatment Plan-1

    [Documentation]    Create MedicalRecordPrescription Template

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
   

JD-TC-Create Treatment Plan-2

    [Documentation]   Adding second  Template

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}
   



JD-TC-Create Treatment Plan-3

    [Documentation]   Create MedicalRecordPrescription Template where template name contain  255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-4

    [Documentation]   Create MedicalRecordPrescription Template where instructions contain 255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-5

    [Documentation]   Create MedicalRecordPrescription Template where medicine name contain  255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-6

    [Documentation]   Create MedicalRecordPrescription Template where template name contain  numbers

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-7

    [Documentation]   Create MedicalRecordPrescription Template contain empty prescription list

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  Random Int  min=500   max=1000
    Set Test Variable    ${templateName1}

    ${prescription}=    Create Dictionary     

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]}     {}
  

JD-TC-Create Treatment Plan-8

    [Documentation]   Create MedicalRecordPrescription Template where template name contain title contain numbers

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${frequency2}=  Random Int  min=500   max=1000
    Set Test Variable    ${frequency2}
    ${duration2}=  Random Int  min=1   max=100
    Set Test Variable    ${duration2}
    ${instructions2}=  FakerLibrary.name
    Set Test Variable    ${instructions2}
    ${dosage2}=  Random Int  min=500   max=1000
    Set Test Variable    ${dosage2}
    ${medicineName2}=  FakerLibrary.name
    Set Test Variable    ${medicineName2}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1}
     ${prescription1}=    Create Dictionary    frequency=${frequency2}  duration=${duration2}  instructions=${instructions2}  dosage=${dosage2}   medicineName=${medicineName2}  

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}   ${prescription1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}
     Should Be Equal As Strings    ${resp.json()['prescriptionDto'][1]['medicineName']}     ${medicineName2}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][1]['frequency']}     ${frequency2}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][1]['duration']}     ${duration2}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][1]['instructions']}     ${instructions2}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][1]['dosage']}     ${dosage2}

JD-TC-Create Treatment Plan-9

    [Documentation]     Create prescription Template Where medicine name as empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${empty} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-10

    [Documentation]     Create prescription Template Where dosage as empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${instructions1}  dosage=${empty}   medicineName=${medicineName1} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${empty}
   
JD-TC-Create Treatment Plan-11

    [Documentation]     Create prescription Template Where instructions empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${duration1}  instructions=${empty}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-12

    [Documentation]     Create prescription Template Where duration is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${frequency1}  duration=${empty}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}

JD-TC-Create Treatment Plan-13

    [Documentation]     Create prescription Template Where frequency is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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
    ${medicineName1}=  FakerLibrary.name
    Set Test Variable    ${medicineName1}
    

    ${prescription}=    Create Dictionary    frequency=${empty}  duration=${duration1}  instructions=${instructions1}  dosage=${dosage1}   medicineName=${medicineName1} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId1} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName1} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions1}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage1}
JD-TC-Create Treatment Plan-UH1

    [Documentation]   Create MedicalRecordPrescription Template with Consumer login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME70}

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    ${email}=    FakerLibrary.Email

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200  
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}    ${countryCodes[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${prescription}=    Create Dictionary    frequency=${frequency}  duration=${duration}  instructions=${instructions}  dosage=${dosage}   medicineName=${medicineName} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName}  ${prescription}
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}

JD-TC-Create Treatment Plan-UH2

    [Documentation]    Create MedicalRecordPrescription Template without login
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

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create Treatment Plan-UH3

    [Documentation]   Create MedicalRecordPrescription Template where template name is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
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

    ${resp}=    Create MedicalRecordPrescription Template    ${empty}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${TEMPLATE_NAME_REQUIRED}
  
JD-TC-Create Treatment Plan-UH4

    [Documentation]   Create MedicalRecordPrescription Template where prescription dictionary is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${templateName1}=  Random Int  min=500   max=1000
    Set Test Variable    ${templateName1}

    ${prescription}=    Create Dictionary    frequency=${EMPTY}  duration=${EMPTY}  instructions=${EMPTY}  dosage=${EMPTY}   medicineName=${EMPTY} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName1}    ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${temId1}    ${resp.json()}

    ${resp}=    Get MedicalPrescription Template By Id   ${temId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Create Treatment Plan-UH5

    [Documentation]    Created same Prescription Template 

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${prescription}=    Create Dictionary    frequency=${frequency}  duration=${duration}  instructions=${instructions}  dosage=${dosage}   medicineName=${medicineName} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NAME_ALREADY_EXISTS}

