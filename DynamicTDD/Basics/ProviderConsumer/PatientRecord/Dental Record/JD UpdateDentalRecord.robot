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
JD-TC-Update Dental Record-1

    [Documentation]    Create a Dental Record and update the toothNo.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
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

    ${toothNo}=   Random Int  min=1   max=47
    Set Suite Variable      ${toothNo}
    ${note1}=  FakerLibrary.word
    Set Suite Variable      ${note1}
    ${investigation}=    Create List   ${note1}
    Set Suite Variable      ${investigation}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}
    # Set Suite Variable      ${toothSurfaces}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id}           ${resp.json()}

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

    ${toothNo1}=   Random Int  min=1   max=47
    Set Suite Variable      ${toothNo1}

    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
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

JD-TC-Update Dental Record-2

    [Documentation]    Update Dental record with tooth type as child.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-2

    [Documentation]    Update Dental record with Investigation is empty.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${investigation1}=    Create List   

    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation1}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation']}     ${investigation1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-3

    [Documentation]    Update Dental records with Investigation notes containing numbers.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inve}=   Random Int  min=1   max=47
    ${investigation1}=    Create List   ${inve}


    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation1}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${inve} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-4

    [Documentation]    Updating a Dental record with a tooth surface is LINGUAL.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothSurfaces1}=  Create List     ${toothSurfaces[1]}


    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[1]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-5

    [Documentation]    Updating a Dental record with a tooth surface is PALATAL.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothSurfaces1}=  Create List   ${toothSurfaces[2]}


    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[2]} 
    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-6

    [Documentation]    Update Dental record with multiple  tooth surfaces.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothSurfaces1}=  Create List   ${toothSurfaces[2]}   ${toothSurfaces[0]}   ${toothSurfaces[1]}  


    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][0]}     ${toothSurfaces[2]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][1]}     ${toothSurfaces[0]} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces'][2]}     ${toothSurfaces[1]} 

    Should Be Equal As Strings    ${resp.json()['provider']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['provider']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['provider']['lastName']}     ${pdrlname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname}

JD-TC-Update Dental Record-7

    [Documentation]    Update Dental records with the tooth surface empty.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothSurfaces1}=  Create List   


    ${resp}=    Update DentalRecord    ${id}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${note1} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces']}     ${toothSurfaces1} 

JD-TC-Update Dental Record-8

    [Documentation]    Update Dental records with the tooth surface empty.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothSurfaces1}=  Create List   
    ${id3}=    FakerLibrary.name

    ${resp}=    Update DentalRecord    ${id3}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id3}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id3} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${investigation} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces']}     ${toothSurfaces1} 

JD-TC-Update Dental Record-9

    [Documentation]    UUpdating Dental records with the tooth surface is invalid.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${id3}=    FakerLibrary.name
    ${toothSurfaces1}=  Create List   ${id3}

    ${resp}=    Update DentalRecord    ${id3}    ${toothNo1}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces1}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get DentalRecord ById   ${id3}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id3} 
    Should Be Equal As Strings    ${resp.json()['toothNo']}     ${toothNo1} 
    Should Be Equal As Strings    ${resp.json()['toothType']}     ${toothType[1]} 
    Should Be Equal As Strings    ${resp.json()['orginUid']}     ${caseUId} 

    Should Be Equal As Strings    ${resp.json()['investigation'][0]}     ${investigation} 
    Should Be Equal As Strings    ${resp.json()['toothSurfaces']}     ${toothSurfaces1} 

JD-TC-Update Dental Record-UH

    [Documentation]    Update Dental Record with another provider login.

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=    Update DentalRecord    ${id}    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NO_PERMISSION}

JD-TC-Update Dental Record-UH

    [Documentation]   Update Dental Record without login.

    ${resp}=    Update DentalRecord    ${id}    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   419
    Should Be Equal As Strings              ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Dental Record-UH

    [Documentation]   Update Dental Record with consumer login.

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update DentalRecord    ${id}    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}