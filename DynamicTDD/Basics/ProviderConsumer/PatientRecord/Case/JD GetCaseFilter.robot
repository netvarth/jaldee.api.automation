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

JD-TC-Get Case Filter-1

    [Documentation]   Get Case Filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
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

     ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${category}=  Create Dictionary  id=${category_id}  

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  

    ${type}=  Create Dictionary  id=${type_id}  
    ${doctor}=  Create Dictionary  id=${pid} 
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

    

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 

     ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${title1}=  FakerLibrary.name

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Suite Variable    ${referenceNo}            ${resp.json()['referenceNo']}
    Set Suite Variable    ${spInternalStatus}            ${resp.json()['spInternalStatus']}


    ${resp}=   Get Case Filter   uid-eq=${caseUId}   referenceNo-eq=${referenceNo}   title-eq=${title1}   consumerId-eq=${cid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description} 
    Should Be Equal As Strings    ${resp.json()[0]['updatedByName']}     ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['updatedBy']}     ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['updatedDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdByName']}     ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['createdBy']}     ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['spInternalStatus']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['spInternalStatus']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['consumer']['firstName']}     ${proconfname}
    Should Be Equal As Strings    ${resp.json()[0]['consumer']['lastName']}     ${proconlname}
    Should Be Equal As Strings    ${resp.json()[0]['doctor']['firstName']}     ${pdrfname}
    Should Be Equal As Strings    ${resp.json()[0]['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()[0]['type']['id']}     ${type_id}


JD-TC-Get Case Filter-2

    [Documentation]    Update MR Case title contain 250 words and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${title1}=  FakerLibrary.Text      max_nb_chars=250

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   uid-eq=${caseUId}   consumerFirstName-eq=${proconfname}   consumerLastName-eq=${proconlname}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description} 

JD-TC-Get Case Filter-3

    [Documentation]    Update MR Case description contain 255 words  and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Text      max_nb_chars=255

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   doctorId-eq=${pid}   doctorFirstName-eq=${pdrfname}   doctorLastName-eq=${pdrlname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Get Case Filter-4

    [Documentation]    Update MR Case title contain numbers  and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.Random Number
   ${description}=  FakerLibrary.Text      max_nb_chars=255

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   category-eq=${category_id}   categoryName-eq=${name}   type-eq=${type_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Get Case Filter-5

    [Documentation]    Update MR Case description contain numbers  and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Random Number

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter  uid-eq=${caseUId}  typeName-eq=${name}   spInternalStatus-eq=${spInternalStatus}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Get Case Filter-6

    [Documentation]    Update MR Case title is empty  and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${description}=  FakerLibrary.Text      max_nb_chars=255

    ${resp}=    Update MR Case    ${caseUId}  ${empty}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   createdDate-eq=${DAY1}  updatedDate-eq=${DAY1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${empty} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Get Case Filter-7

    [Documentation]    Update MR Case from user login and get case filter

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accoun_Id}        ${resp.json()['id']}  
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${dep_id}  ${resp1.json()}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${sam_email}     ${resp.json()['email']}

    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Text      max_nb_chars=255

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${empty}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter    uid-eq=${caseUId}   title-eq=${title1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${empty}

JD-TC-Get Case Filter-UH1

    [Documentation]    Get Case Filter- without login

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

D-TC-Get Case Filter-UH2

    [Documentation]    Get Case Filter- with another provider login
    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    []