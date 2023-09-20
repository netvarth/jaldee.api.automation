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
    ${resp}=  POST On Session  ynw  /provider/medicalrecord/type/category  data=${data}  expected_status=any
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