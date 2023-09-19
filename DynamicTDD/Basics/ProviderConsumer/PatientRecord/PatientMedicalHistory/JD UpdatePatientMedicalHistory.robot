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

*** Keywords ***

Add Patient Medical History

    [Arguments]    ${providerConsumerId}  ${title}  ${description}  ${viewByUsers}   @{vargs}
    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    providerConsumerId=${providerConsumerId}  title=${title}  description=${description}    viewByUsers=${viewByUsers}  medicalHistoryAttachments=${AttachmentList}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    POST On Session    ynw    provider/medicalrecord/medicalHistory    data=${data}    expected_status=any
    [Return]  ${resp}

Update Patient Medical History

    [Arguments]    ${id}  ${title}  ${description}  ${viewByUsers}  @{vargs}
    ${len}=  Get Length  ${vargs}
    ${AttachmentList}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${AttachmentList}  ${vargs[${index}]}
    END
    ${data}=    Create Dictionary    id=${id}  title=${title}  description=${description}    viewByUsers=${viewByUsers}   medicalHistoryAttachments=${AttachmentList}
    Check And Create YNW Session
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    provider/medicalrecord/medicalHistory/${medicalHistoryId}    data=${data}     expected_status=any
    [Return]  ${resp}

Delete Patient Medical History

    [Arguments]    ${medicalHistoryId}  
    ${resp}=    DELETE On Session    ynw   /provider/medicalrecord/medicalHistory/${medicalHistoryId}        expected_status=any
    [Return]  ${resp}

Get Patient Medical History

    [Arguments]    ${providerConsumerId}  
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/medicalHistory/${providerConsumerId}        expected_status=any
    [Return]  ${resp}


*** Variables ***

@{emptylist}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${mp4file}      /ebs/TDD/MP4file.mp4
${mp3file}      /ebs/TDD/MP3file.mp3
${order}    0
${fileSize}    0.00458
${title1}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***


JD-TC-Update Patient Medical History-1

    [Documentation]    Update Patient Medical History

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
    Set Suite Variable    ${pid}        ${resp.json()['id']}
    Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${caption}=  FakerLibrary.name
    Set Suite Variable    ${caption}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}
    ${users}=   Create List  
    ${fileName}=    FakerLibrary.File Name
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType}


    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${attachements}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId}
    
    ${resp}=    Add Patient Medical History   ${cid}    ${title}    ${description}    ${users}  ${attachements} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Set Suite Variable    ${medicalHistory_id}    ${resp.json()[0]['id']}   

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId2}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements2}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId2}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-2

    [Documentation]    Update Provider Consumer Medical history where description is empty.


    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${EMPTY}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${EMPTY}

JD-TC-Update Patient Medical History-3

    [Documentation]    Update Provider Consumer Medical history where title is empty.

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.last_name
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${EMPTY}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${EMPTY}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-4

    [Documentation]    Update Provider Consumer Medical history where description is different

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.Random Number
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-5

    [Documentation]    Update Provider Consumer Medical history where description contain 255 words.

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.name
    ${description1}=  FakerLibrary.Text     	max_nb_chars=255
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-6

    [Documentation]    Update Provider Consumer Medical history where title contains 255 words.

    ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.Text        max_nb_chars=255
    ${description1}=  FakerLibrary.name     	
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

 