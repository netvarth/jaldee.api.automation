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

*** Keywords ***

Create Treatment Plan

    [Arguments]      ${caseDto}  ${treatment}  ${works}  &{kwargs}
    ${data}=  Create Dictionary    caseDto=${caseDto}  treatment=${treatment}  works=${works} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/treatment  data=${data}  expected_status=any
    [Return]  ${resp}

Update Treatment Plan

    [Arguments]     ${id}  ${caseDto}  ${treatment}  ${works}  &{kwargs}
    ${data}=  Create Dictionary    id=${id}  caseDto=${caseDto}  treatment=${treatment}  works=${works} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/treatment  data=${data}  expected_status=any
    [Return]  ${resp}

Update Treatment Plan Work status
    [Arguments]     ${treatmentId}  ${workId}  ${status}  &{kwargs}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/treatment/${treatmentId}/${workId}/${status}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Treatment Plan By Id
    [Arguments]     ${id}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/${Id}  expected_status=any
    [Return]  ${resp}

Get Treatment Plan By case Id
    [Arguments]     ${uid}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /provider/medicalrecord/treatment/case/${uid}  expected_status=any
    [Return]  ${resp}

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

JD-TC-Update Treatment Plan-1

    [Documentation]    Update Treatment Plan

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

    

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer} 

     ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${caseDto}=  Create Dictionary  uid=${caseUId} 
    Set Suite Variable    ${caseDto} 
    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${caseDto}  ${treatment}  ${works}  
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

    ${work}=  FakerLibrary.name
    ${work1}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    # ${two}=  Create Dictionary  work=${work1}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}  

    ${resp}=    Update Treatment Plan   ${treatmentId}  ${caseDto}  ${treatment}  ${works}  
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
    #  Should Be Equal As Strings    ${resp.json()['works'][1]['status']}     ${PRStatus[0]}
    # Should Be Equal As Strings    ${resp.json()['works'][1]['work']}     ${work1}
    # Should Be Equal As Strings    ${resp.json()['works'][1]['createdDate']}     ${DAY1}


