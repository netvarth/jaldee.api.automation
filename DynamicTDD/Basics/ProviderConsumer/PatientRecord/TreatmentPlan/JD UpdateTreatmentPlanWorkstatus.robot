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

JD-TC-Update Treatment Plan Work status-1

    [Documentation]    Update Treatment Plan Work status

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
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

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${DAY1}=  get_date
    Set Suite Variable    ${DAY1}

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${category}=  Create Dictionary  id=${category_id}  
    Set Suite Variable    ${category} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  

    ${type}=  Create Dictionary  id=${type_id} 
    Set Suite Variable    ${type}  
    ${doctor}=  Create Dictionary  id=${pid} 
    Set Suite Variable    ${doctor} 
    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

     ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer} 

     ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}    ${toothSurfaces[1]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable       ${id1}          ${resp.json()}
    # Set Test Variable      ${uid}           ${resp.json()["uid"]}

    ${resp}=    Get DentalRecord ById   ${id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id1} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[0]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[1]}

    # ${caseDto}=  Create Dictionary  uid=${caseUId} 
    # Set Suite Variable    ${caseDto} 
    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${WorkStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}   ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${workId}        ${resp.json()['works'][0]['id']}   
    Should Be Equal As Strings    ${resp.json()['caseDto']['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['caseDto']['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['category']['id']}     ${category_id} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['createdDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()['treatment']}     ${treatment}
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${WorkStatus[0]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}

    ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[2]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${WorkStatus[2]}
JD-TC-Update Treatment Plan Work status-2

    [Documentation]    Update Treatment Plan Work status as CLOSED

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    # ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[2]}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings              ${resp.status_code}   200
    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Update Treatment Plan Work status-UH1

    [Documentation]    Update Treatment Plan Work status that already complete status

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[2]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${STATUS_COMPLETE}

JD-TC-Update Treatment Plan Work status-UH2

    [Documentation]    Update Treatment Plan Work status without login

    ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[2]}  
    Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Treatment Plan Work status-UH3

    [Documentation]    Update Treatment Plan Work status with another login

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[2]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Update Treatment Plan Work status-UH4

    [Documentation]    Update Treatment Plan Work status where treatment id is invalid

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${fake_id}=  Random Int  min=500   max=1000


   ${resp}=    Update Treatment Plan Work status    ${fake_id}  ${workId}  ${WorkStatus[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_TREATMENT_REQUEST}"

JD-TC-Update Treatment Plan Work status-UH5

    [Documentation]    Update Treatment Plan Work status where work id is invalid

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${fake_id}=  Random Int  min=500   max=1000
   ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${fake_id}  ${WorkStatus[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_WORK_ID}"


JD-TC-Update Treatment Plan Work status-UH6

    [Documentation]    Update Treatment Plan Work status that already open status

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${WorkStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}   ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable    ${treatmentId1}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${workId}        ${resp.json()['works'][0]['id']}   



    # ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${WorkStatus[0]}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings              ${resp.status_code}  200

    ${resp}=    Update Treatment Plan Work status    ${treatmentId1}  ${workId}  ${WorkStatus[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${STATUS_OPEN}


*** comment ***

JD-TC-Update Treatment Plan Work status-UH6

    [Documentation]    Update Treatment Plan Work status where status invalid

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${fake_id}=  Random Int  min=500   max=1000
   ${resp}=    Update Treatment Plan Work status    ${treatmentId}  ${workId}  ${fake_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_ID}"                 # They cant fix this,because of enum value

    



