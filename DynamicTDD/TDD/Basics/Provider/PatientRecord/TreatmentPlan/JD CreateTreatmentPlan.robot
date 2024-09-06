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

JD-TC-Create Treatment Plan-1

    [Documentation]    Create Treatment Plan

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
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

    

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
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
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}


JD-TC-Create Treatment Plan-2

    [Documentation]    Create 2 more Treatment Plan

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    # ${work1}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    # ${two}=  Create Dictionary  work=${work1}   status=${QnrStatus[1]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId1}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}
    # Should Be Equal As Strings    ${resp.json()['works'][1]['status']}     ${QnrStatus[1]}
    # Should Be Equal As Strings    ${resp.json()['works'][1]['work']}     ${work1}
    # Should Be Equal As Strings    ${resp.json()['works'][1]['createdDate']}     ${DAY1}


JD-TC-Create Treatment Plan-3

    [Documentation]    Create Treatment Plan where treatment field contain 250 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.Text      max_nb_chars=250
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId3}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId3}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}

JD-TC-Create Treatment Plan-4

    [Documentation]    Create Treatment Plan where work field contain 250 words

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.Text      max_nb_chars=250
    ${one}=  Create Dictionary  work=${work}   status=${QnrStatus[1]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId4}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId4}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${QnrStatus[1]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}

JD-TC-Create Treatment Plan-5

    [Documentation]    Create Treatment Plan where treatment is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${empty}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId5}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId5}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['caseDto']['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['caseDto']['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['category']['id']}     ${category_id} 
    Should Be Equal As Strings    ${resp.json()['caseDto']['createdDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()['treatment']}     ${empty}
    Should Be Equal As Strings    ${resp.json()['works'][0]['status']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()['works'][0]['createdDate']}     ${DAY1}

JD-TC-Create Treatment Plan-6

    [Documentation]    Create Treatment Plan where works list is empty

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List   

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId6}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId6}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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
  
JD-TC-Create Treatment Plan-7

    [Documentation]    Create a Treatment Plan, then assign a user. 

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
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

    # ${resp}=  SendProviderResetMail   ${sam_email}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List   ${one}
    ${assignee}=  Create List   ${u_id}

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  assignees=${assignee}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable    ${treatmentId}        ${resp.json()}

    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['assignees'][0]}     ${u_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Treatment Plan By Id   ${treatmentId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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
    Should Be Equal As Strings    ${resp.json()['assignees'][0]}     ${u_id}

JD-TC-Create Treatment Plan-UH1

    [Documentation]    Create Treatment Plan using another provider login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Create Treatment Plan-UH2

    [Documentation]    Create Treatment Plan without login

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.Text      max_nb_chars=250
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}   ${id1}   ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}



JD-TC-Create Treatment Plan-UH4

    [Documentation]    Create Treatment Plan where case dto uid is invalid

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  
    ${fake_id}=  Random Int  min=500   max=1000
    # ${caseDto1}=  Create Dictionary  uid=${fake_id} 

    ${resp}=    Create Treatment Plan    ${fake_id}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_CASE_ID}"

JD-TC-Create Treatment Plan-UH5

    [Documentation]    Create Treatment Plan using provider consumer login

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.Text      max_nb_chars=250
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${caseUId}    ${id1}  ${treatment}  ${works}  
    Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NoAccess}


*** Comments ***
JD-TC-Create Treatment Plan-UH3

    [Documentation]    Create Treatment Plan where casedto is empty            #cant able to pass empty dto.need a an empty dictionary insteadvb

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Create Treatment Plan    ${empty}  ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   422
    
  

