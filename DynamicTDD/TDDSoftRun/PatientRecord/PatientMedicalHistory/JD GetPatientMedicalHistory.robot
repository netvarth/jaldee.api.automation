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

JD-TC-Get Patient Medical History-1

    [Documentation]    Get Patient Medical History.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}


    # ${resp}=   ProviderLogin  ${PUSERNAME13}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings          ${resp.status_code}   200
    # Set Suite Variable    ${pid}        ${resp.json()['id']}
    # Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

    ${resp}=    Consumer Logout 
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

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}
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

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId1}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachements1}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId1}



    ${resp}=    Add Patient Medical History   ${cid}    ${title}    ${description}    ${users}  ${attachements}   ${attachements1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Set Suite Variable    ${medicalHistory_id}    ${resp.json()[0]['id']}   

JD-TC-Get Patient Medical History-2

    [Documentation]    Adding Provider consumer Medical history where title contain 250 words and get that details using Provider consumer id

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}

    ${title}=  FakerLibrary.Text     	max_nb_chars=250
    ${caption}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
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
    Should Be Equal As Strings    ${resp.json()[1]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[1]['description']}     ${description}
    Set Suite Variable    ${medicalHistory_id}    ${resp.json()[0]['id']}  

JD-TC-Get Patient Medical History-3

    [Documentation]    Adding 2 more Provider Consumer Medical history and get that details using Provider consumer id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
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

    ${resp}=  Encrypted Provider Login    ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title}=  FakerLibrary.Text     	max_nb_chars=250
    ${caption}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${fileName}=    FakerLibrary.File Name
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType}

    ${title2}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${caption}=  FakerLibrary.name
    Set Suite Variable    ${caption}
    ${description2}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

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

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId1}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${attachements1}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId1}

    ${resp}=    Add Patient Medical History   ${cid}    ${title2}    ${description2}    ${users}  ${attachements1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}
    Should Be Equal As Strings    ${resp.json()[1]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[1]['title']}     ${title2}
    Should Be Equal As Strings    ${resp.json()[1]['description']}     ${description2}

JD-TC-Get Patient Medical History-4

    [Documentation]    Adding Provider Consumer Medical history  where the title is empty.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
         

    # ${title}=  FakerLibrary.Text     	max_nb_chars=260
    ${caption}=  FakerLibrary.name
    ${description}=  FakerLibrary.last_name
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

    ${resp}=    Add Patient Medical History   ${cid}    ${EMPTY}    ${description}    ${users}  ${attachements}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[2]['providerConsumerId']}     ${cid}
    Should Not contain    ${resp.json()[2] }    title
    Should Be Equal As Strings    ${resp.json()[2]['description']}     ${description}
 
JD-TC-Get Patient Medical History-5

    [Documentation]   Adding  Provider Consumer Medical history where description is empty.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
        
    ${title}=  FakerLibrary.Text     	
    ${caption}=  FakerLibrary.name
    # ${description}=  FakerLibrary.last_name
    ${users}=   Create List  

    ${fileName}=    FakerLibrary.File Name
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType}


    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${attachements}=  Create Dictionary   fileName=${jpgfile}   fileSize=${fileSize}   fileType= ${fileType}   action=${file_action[0]}  driveId=${driveId}

    ${resp}=    Add Patient Medical History   ${cid}    ${title}    ${EMPTY}    ${users}  ${attachements}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[3]['providerConsumerId']}     ${cid}
    Should Be Equal As Strings    ${resp.json()[3]['title']}     ${title}
    Should Not contain    ${resp.json()[3]}     description

JD-TC-Get Patient Medical History-6

    [Documentation]    Adding Patient Medical History

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
    

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

    ${resp}=    Consumer Logout 
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

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
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

    ${resp}=    Delete Patient Medical History    ${medicalHistory_id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Patient Medical History     ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}   []


JD-TC-Get Patient Medical History-UH1

    [Documentation]    Get Patient medical record using another provider login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200

    ${resp}=    Get Patient Medical History     ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}

JD-TC-Get Provider Consumer Notes-UH2

    [Documentation]   Get Patient medical record without login.

    ${resp}=    Get Patient Medical History     ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Provider Consumer Notes-UH3

    [Documentation]   GGet Patient medical record with Consumer login.

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
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  
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
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Patient Medical History     ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}
