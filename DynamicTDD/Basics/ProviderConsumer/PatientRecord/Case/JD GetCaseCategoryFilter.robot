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

Encrypted Provider Login
    [Arguments]    ${usname}  ${passwrd}   ${countryCode}=91
    ${data}=  Login  ${usname}  ${passwrd}   countryCode=${countryCode}
    ${encrypted_data}=  db.ecrypt_data  ${data}
    ${data}=    json.dumps    ${encrypted_data}
    ${resp}=    POST On Session    ynw    /provider/login/encrypt    data=${data}  expected_status=any
    [Return]  ${resp}

Create Case Category

    [Arguments]      ${name}  ${aliasName}  &{kwargs}
    ${data}=  Create Dictionary    name=${name}  aliasName=${aliasName} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case/category  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Category

    [Arguments]     ${Id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/category/${id}        expected_status=any
    [Return]  ${resp}

Update Case Category

    [Arguments]     ${id}  ${name}  ${aliasName}  ${status}  &{kwargs}
    ${data}=  Create Dictionary  name=${name}  aliasName=${aliasName}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/category/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Category Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case/category      expected_status=any
    [Return]  ${resp}

Create Case Type

    [Arguments]      ${name}  ${aliasName}  &{kwargs}
    ${data}=  Create Dictionary    name=${name}  aliasName=${aliasName} 
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case/type  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Type

    [Arguments]     ${Id}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/type/${id}  expected_status=any
    [Return]  ${resp}

Update Case Type
    [Arguments]     ${id}  ${name}  ${aliasName}  ${status}  &{kwargs}
    ${data}=  Create Dictionary  name=${name}  aliasName=${aliasName}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/type/${id}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Type Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case/type      expected_status=any
    [Return]  ${resp}

Create MR Case
    [Arguments]      ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  &{kwargs}
    ${data}=  Create Dictionary    category=${category}  type=${type}  doctor=${doctor}  consumer=${consumer}   title=${title}  description=${description}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/case  data=${data}  expected_status=any
    [Return]  ${resp}

Get MR Case By UID
     [Arguments]     ${uid}  
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw    /provider/medicalrecord/case/${uid}  expected_status=any
    [Return]  ${resp}

Update MR Case
    [Arguments]      ${uid}  ${title}  ${description}   &{kwargs}
    ${data}=  Create Dictionary  title=${title}  description=${description}   status=${status}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/${uid}  data=${data}  expected_status=any
    [Return]  ${resp}

Get Case Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/case     expected_status=any
    [Return]  ${resp}

Change Case Status
    [Arguments]      ${uid}  ${statusName} 
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/medicalrecord/case/${uid}/status/${statusName}   expected_status=any
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

JD-TC-Get Case Category Filter-1

    [Documentation]    Get Case Category Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}

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
    ${aliasName1}=  FakerLibrary.name
    Set Suite Variable    ${aliasName1}

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${id}    ${resp.json()['id']} 

    ${resp}=    Get Case Category    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

    ${resp}=    Update Case Category  ${id}  ${name}  ${aliasName1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=    Get Case Category Filter     
    Log   ${resp.content}

    ${resp}=    Get Case Category    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

JD-TC-Get Case Category Filter-2

    [Documentation]    Update Case Category where name contain 255 words and Get Case Category Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=255

    ${resp}=    Update Case Category    ${id}  ${description1}  ${aliasName}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Case Category Filter     
    Log   ${resp.content}

    ${resp}=    Get Case Category    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${description1}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${aliasName}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}

JD-TC-Get Case Category Filter-3

    [Documentation]    Update Case Category where alias name contain 255 words and Get Case Category Filter

    ${resp}=  Encrypted Provider Login    ${PUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${description1}=  FakerLibrary.Text     	max_nb_chars=255

    ${resp}=    Update Case Category    ${id}  ${name}  ${description1}   ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Case Category Filter     
    Log   ${resp.content}

    ${resp}=    Get Case Category    ${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['id']}     ${id} 
    Should Be Equal As Strings    ${resp.json()['account']}     ${accountId} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${name}
    Should Be Equal As Strings    ${resp.json()['aliasName']}     ${description1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]}


JD-TC-Get Case Category Filter-UH1

    [Documentation]    Get Case Category with another provider login

    ${resp}=  Encrypted Provider Login    ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

     ${resp}=    Get Case Category Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}


JD-TC-Get Case Category Filter-UH2

    [Documentation]    Get Case Category without login

    ${resp}=    Get Case Category Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}