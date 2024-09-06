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
# Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-Get MedicalPrescription Template By Id-1

    [Documentation]     Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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
   

JD-TC-Get MedicalPrescription Template By Id-2

    [Documentation]   Adding second  Template and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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
   
JD-TC-Get MedicalPrescription Template By Id-3

    [Documentation]   Create MedicalRecordPrescription Template where template name contain  255 words and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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

JD-TC-Get MedicalPrescription Template By Id-4

    [Documentation]   Create MedicalRecordPrescription Template where instructions contain 255 words and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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

JD-TC-Get MedicalPrescription Template By Id-5

    [Documentation]   Create MedicalRecordPrescription Template where medicine name contain  255 words and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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

JD-TC-Get MedicalPrescription Template By Id-6

    [Documentation]   Create MedicalRecordPrescription Template where template name contain  numbers and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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

JD-TC-Get MedicalPrescription Template By Id-7

    [Documentation]   Create MedicalRecordPrescription Template contain empty prescription list and Get MedicalPrescription Template By Id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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
  

JD-TC-Get MedicalPrescription Template By Id-8

    [Documentation]   Get MedicalPrescription Template By Id-Create MedicalRecordPrescription Template where template name contain title contain numbers 

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
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

JD-TC-Get MedicalPrescription Template By Id-9

    [Documentation]    Update MedicalRecordPrescription Template and Get MedicalPrescription Template By Id

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

JD-TC-Get MedicalPrescription Template By Id-UH1

    [Documentation]   Get MedicalPrescription Template By Id with another provider login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Get MedicalPrescription Template By Id-UH2

    [Documentation]    Get MedicalPrescription Template By Id without login

    ${resp}=    Get MedicalPrescription Template By Id   ${temId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get MedicalPrescription Template By Id-UH3

    [Documentation]   Get MedicalPrescription Template By Id with invalid id

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${invalid}=   Random Int  min=123   max=400
    
    ${resp}=    Get MedicalPrescription Template By Id    ${invalid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
  
