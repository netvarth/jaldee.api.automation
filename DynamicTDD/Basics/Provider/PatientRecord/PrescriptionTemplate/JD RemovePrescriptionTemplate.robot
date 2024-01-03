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
Variables         /ebs/TDD/varfiles/hl_musers.py




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

JD-TC-Remove Prescription Template-1

    [Documentation]    Remove Prescription Template

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME21}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['id']}     ${temId} 
    Should Be Equal As Strings    ${resp.json()['templateName']}     ${templateName} 
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['medicineName']}     ${medicineName}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['frequency']}     ${frequency}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['duration']}     ${duration}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['instructions']}     ${instructions}
    Should Be Equal As Strings    ${resp.json()['prescriptionDto'][0]['dosage']}     ${dosage}

    ${resp}=    Remove Prescription Template    ${temId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Prescription Template By Account Id    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings   ${resp.content}   []
   

JD-TC-Remove Prescription Template-UH1

    [Documentation]   Delete already deleted prescription template

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME21}  ${PASSWORD}
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
   
    ${resp}=    Remove Prescription Template    ${temId1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Prescription Template By Account Id    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings   ${resp.content}   []

    ${resp}=    Remove Prescription Template    ${temId1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}   ${boolean[0]}

JD-TC-Remove Prescription Template-UH2

    [Documentation]    Remove Prescription Template without login

    ${resp}=   Remove Prescription Template    ${temId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Remove Prescription Template-UH3

    [Documentation]   Remove Prescription Template with another login

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=    Remove Prescription Template    ${temId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings              ${resp.json()}   ${bool[0]}

JD-TC-Remove Prescription Template-UH4

    [Documentation]   Remove Prescription Template with  consumer login.

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Remove Prescription Template    ${temId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}

JD-TC-Remove Prescription Template-UH5

    [Documentation]   Remove Prescription Template with  invalid id..

     ${resp}=  Encrypted Provider Login    ${HLMUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=   Random Int  min=123   max=400

    ${resp}=    Remove Prescription Template    ${invalid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}   ${bool[0]}




