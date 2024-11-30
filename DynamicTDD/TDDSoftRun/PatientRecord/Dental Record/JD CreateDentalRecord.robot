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
JD-TC-Create Dental Record-1

    [Documentation]    Create a Dental Record.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
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

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
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


JD-TC-Create Dental Record-2

    [Documentation]    Create Dental record with tooth type as child.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-3

    [Documentation]    Create Dental record with Investigation is empty.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-4

    [Documentation]    Create Dental records with Investigation notes containing numbers.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  Random Int  min=1   max=47
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-5

    [Documentation]    Creating a Dental record with a tooth surface is LINGUAL.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[1]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-6

    [Documentation]    Creating a Dental record with a tooth surface is PALATAL.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-7

    [Documentation]    Creating a Dental record with multiple  tooth surfaces.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-8

    [Documentation]    Creating a Dental record with multiple  investigation.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    Set Suite Variable    ${toothNo}
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-9

    [Documentation]    Create Dental records with the tooth surface empty.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    # ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}   
    ${toothSurfaces}=    Create List  

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-10

    [Documentation]    Try to Create Dental record with already created tooth number.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

JD-TC-Create Dental Record-11

    [Documentation]    Try to Create Dental record with toothConditions field.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothConditions}    Random Element  ${toothConditions}
    ${toothConditions}=    Create List   ${toothConditions}    

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}   toothConditions=${toothConditions}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200    

JD-TC-Create Dental Record-12

    [Documentation]    Try to Create Dental record with toothRestorations field.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothRestorations}    Random Element  ${toothRestorations}
    ${toothRestorations}=    Create List   ${toothRestorations}    

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}   toothRestorations=${toothRestorations}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200 

JD-TC-Create Dental Record-13

    [Documentation]    Try to Create Dental record with all the fields.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}
    ${toothConditions}    Random Element  ${toothConditions}
    ${toothConditions}=    Create List   ${toothConditions}    

    ${toothRestorations}    Random Element  ${toothRestorations}
    ${toothRestorations}=    Create List   ${toothRestorations}    

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}      toothConditions=${toothConditions}    toothRestorations=${toothRestorations}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200 

JD-TC-Create Dental Record-UH1

    [Documentation]    Create Dental Record with another provider login.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings              ${resp.json()}   ${NO_PERMISSION}

JD-TC-Create Dental Record-UH2

    [Documentation]    Create Dental Record without login.

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   419
    Should Be Equal As Strings              ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create Dental Record-UH3

    [Documentation]    Create Dental Record with Provider consumer login.

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
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
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

    # ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${toothNo}=   Random Int  min=10   max=47
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[1]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}

*** Comments ***

JD-TC-Create Dental Record-UH1

    [Documentation]    Create Dental records with tooth type as invalid.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${toothNo}=   FakerLibrary.word
    ${note1}=  FakerLibrary.word
    ${note2}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}    ${note2}
    ${toothSurfaces}=    Create List   ${toothSurfaces[2]}    ${toothSurfaces[1]}    ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${EMPTY}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings              ${resp.json()}   ${TOOTH_ID_CANNOT_BE_EMPTY}
