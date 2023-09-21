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
${titles}    @sdf@123
${descriptions}    &^7gsdkqwrrf

*** Test Cases ***


JD-TC-Update Patient Medical History-1

    [Documentation]    Update Patient Medical History

    ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    # ${resp}=   ProviderLogin  ${PUSERNAME12}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings          ${resp.status_code}   200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}



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

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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


     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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
    

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${SPACE}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${SPACE}

JD-TC-Update Patient Medical History-3

    [Documentation]    Update Provider Consumer Medical history where title is empty.

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history where medicalHistory id is invalid.

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.Text       
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
    
    ${medicalHistory_id}=  FakerLibrary.name     	

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history where the title contains numbers.

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.Random Number       
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

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history where the title contains special characters.

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    # ${title1}=  FakerLibrary.name      
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

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${titles}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${titles}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description1}

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history where the description contains special characters.

     ${resp}=  Encrypted Provider Login    ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name      
    # ${description1}=  FakerLibrary.name     	
    ${users1}=   Create List  
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId3}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements3}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId3}   	

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${descriptions}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History    ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${descriptions}

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history using another provider login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${title1}=  FakerLibrary.name      
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
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history using another consumer login.

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title1}=  FakerLibrary.name      
    ${description1}=  FakerLibrary.name     	
    ${users1}=   Create List  
    
    ${attachements3}=  Create Dictionary   

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}

JD-TC-Update Patient Medical History-UH

    [Documentation]    Update Provider Consumer Medical history without login.

    ${title1}=  FakerLibrary.name      
    ${description1}=  FakerLibrary.name     	
    ${users1}=   Create List  
    
    ${attachements3}=  Create Dictionary   

    ${resp}=    Update Patient Medical History   ${medicalHistory_id}    ${title1}    ${description1}    ${users1}   ${attachements3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}



 