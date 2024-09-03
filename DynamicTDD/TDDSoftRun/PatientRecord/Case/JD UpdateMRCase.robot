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

JD-TC-Update MR Case-1

    [Documentation]    Update MR Case

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
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
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer}

    ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}


    ${title1}=  FakerLibrary.name

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description} 

JD-TC-Update MR Case-2

    [Documentation]    Update MR Case title contain 250 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${title1}=  FakerLibrary.Text      max_nb_chars=250

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description} 

JD-TC-Update MR Case-3

    [Documentation]    Update MR Case description contain 250 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Text      max_nb_chars=250

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Update MR Case-4

    [Documentation]    Update MR Case title contain numbers

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.Random Number
   ${description}=  FakerLibrary.Text      max_nb_chars=250

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Update MR Case-5

    [Documentation]    Update MR Case description contain numbers

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Random Number

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Update MR Case-7

    [Documentation]    Update MR Case title is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

   ${description}=  FakerLibrary.Text      

    ${resp}=    Update MR Case    ${caseUId}  ${empty}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${empty} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${description}

JD-TC-Update MR Case-8

    [Documentation]    Update MR Case from user login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
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

    ${resp}=    Reset LoginId  ${u_id}  ${PUSERNAME_U1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U1}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U1}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200


    ${title1}=  FakerLibrary.name
    ${description}=  FakerLibrary.Text      max_nb_chars=250

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${empty}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=   Get Case Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['title']}     ${title1} 
    Should Be Equal As Strings    ${resp.json()[0]['description']}     ${empty}

JD-TC-Update MR Case-9

    [Documentation]    Create a MR Case with Assign Then Update MR Case Assignee with another user.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${u_id2}=  Create Sample User
    Set Test Variable  ${u_id2}

    ${usr}=  Create List      ${u_id}

    ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  assignees=${usr}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Test Variable    ${caseUId1}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['createdDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()['title']}     ${title}
    Should Be Equal As Strings    ${resp.json()['description']}     ${description}
    Should Be Equal As Strings    ${resp.json()['assignees'][0]}     ${u_id}
    # Should Be Equal As Strings    ${resp.json()['assignees'][1]}     ${pid}

    ${title1}=  FakerLibrary.name
    ${description}=  FakerLibrary.Text      max_nb_chars=250

    ${usr}=  Create List      ${u_id2}

    ${resp}=    Update MR Case    ${caseUId1}  ${title1}  ${description}   assignees=${usr} 
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get MR Case By UID   ${caseUId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['createdDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()['title']}     ${title1}
    Should Be Equal As Strings    ${resp.json()['description']}     ${description}
    Should Be Equal As Strings    ${resp.json()['assignees'][0]}     ${u_id2}
    # Should Be Equal As Strings    ${resp.json()['assignees'][1]}     ${pid}

JD-TC-Update MR Case-UH1

    [Documentation]    Update MR Case description contain more than 255 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Text      max_nb_chars=400

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}    ${CASE_DESCRIPTION_NOT_EXCEED_250CHAR}


JD-TC-Update MR Case-UH2

    [Documentation]    Update MR Case using another provider login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${title1}=  FakerLibrary.name
   ${description}=  FakerLibrary.Text      max_nb_chars=400

    ${resp}=    Update MR Case    ${caseUId}  ${title1}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Update MR Case-UH3

    [Documentation]    Update MR Case without login

    ${resp}=    Update MR Case    ${caseUId}  ${title}  ${description}  
    Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}




   
   