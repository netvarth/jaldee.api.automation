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
JD-TC-Get Dental Record-1

    [Documentation]    Create a Dental Record and verify .

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
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

    ${name}=  FakerLibrary.name
    ${aliasName}=  FakerLibrary.name

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  
 
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

    Log  ${resp.request.headers['Cookie']}
        ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}     ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
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

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    ${category}=  Create Dictionary  id=${category_id}  
    ${type}=  Create Dictionary  id=${type_id}  
    ${doctor}=  Create Dictionary  id=${pid}

    ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['category']['id']}     ${category_id} 

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable      ${id}           ${resp.json()}
    # Set Test Variable      ${uid}           ${resp.json()["uid"]}

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[0]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Get Dental Record-2

    [Documentation]    Create a Dental Record then update toothType and verify .

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${consumer}=  Create Dictionary  id=${cid} 
    ${category}=  Create Dictionary  id=${category_id}  
    ${type}=  Create Dictionary  id=${type_id}  
    ${doctor}=  Create Dictionary  id=${pid}

    ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId1}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId1}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['category']['id']}     ${category_id} 

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId1}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id1}           ${resp.json()}
    # Set Test Variable      ${uid}           ${resp.json()["uid"]}

    ${resp}=    Get DentalRecord ById   ${id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id1} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[0]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId1} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

    ${resp}=    Update DentalRecord    ${id1}    ${toothNo}  ${toothType[1]}  ${caseUId1}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id1} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId1} 

JD-TC-Get Dental Record-3

    [Documentation]    Delete Dental Record and Get that record using id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Delete DentalRecord   ${id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings              ${resp.json()}   ${INVALID_ID}

JD-TC-Get Dental Record-4

    [Documentation]    Creating a Dental record with multiple  tooth surfaces and Get that record using id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}    ${toothSurfaces[1]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId1}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id2}           ${resp.json()}
    # Set Test Variable      ${uid}           ${resp.json()["uid"]}

    ${resp}=    Get DentalRecord ById   ${id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id2} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[0]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId1} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[1]} 

    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Get Dental Record-5

    [Documentation]    Try to Create Dental record with toothConditions field and Get that record by id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothConditions1}    Random Element  ${toothConditions}
    ${toothConditions}=    Create List   ${toothConditions1}    

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}   toothConditions=${toothConditions}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200  
    Set Test Variable      ${id}           ${resp.json()}

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[1]} 
    Should Be Equal As Strings    ${resp.json()['toothConditions'][0]}     ${toothConditions1} 

JD-TC-Get Dental Record-6

    [Documentation]    Try to Create Dental record with toothRestorations field and Get that record by id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothRestorations1}    Random Element  ${toothRestorations}
    ${toothRestorations}=    Create List   ${toothRestorations1}    

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}   toothRestorations=${toothRestorations}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200  
    Set Test Variable      ${id}           ${resp.json()}

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[1]} 
    Should Be Equal As Strings    ${resp.json()['toothRestorations'][0]}     ${toothRestorations1} 

JD-TC-Get Dental Record-7

    [Documentation]    Try to Create Dental record with all the fields and Get that record by id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothRestorations1}    Random Element  ${toothRestorations}
    ${toothRestorations}=    Create List   ${toothRestorations1}   

    ${toothConditions1}    Random Element  ${toothConditions}
    ${toothConditions}=    Create List   ${toothConditions1}   

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}   toothConditions=${toothConditions}   toothRestorations=${toothRestorations}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200  
    Set Test Variable      ${id}           ${resp.json()}

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[1]} 
    Should Be Equal As Strings    ${resp.json()['toothRestorations'][0]}     ${toothRestorations1} 



JD-TC-Get Dental Record-UH1

    [Documentation]    Get Dental records using invalid id.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${id3}=   Random Int  min=120   max=470

    ${resp}=    Get DentalRecord ById   ${id3}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-Get Dental Record-UH2

    [Documentation]    Get Dental Record with another provider login.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get DentalRecord ById   ${id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NO_PERMISSION}

JD-TC-Get Dental Record-UH3

    [Documentation]    Get Dental Record without login.

    ${resp}=    Get DentalRecord ById   ${id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings              ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Dental Record-UH4

    [Documentation]    Get Dental Record with consumer login.

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

    Log  ${resp.request.headers['Cookie']}
        ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}     ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
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

    ${resp}=    Get DentalRecord ById   ${id2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}




