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

Create DentalRecord

    [Arguments]      ${toothNo}  ${toothType}  ${orginUid}   &{kwargs}

    ${data}=  Create Dictionary    toothNo=${toothNo}  toothType=${toothType}  investigation=${investigation}  orginUid=${orginUid}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  provider/dental  data=${data}  expected_status=any
    [Return]  ${resp}


Update DentalRecord

    [Arguments]      ${toothNo}  ${toothType}  ${orginUid}   &{kwargs}

    ${data}=  Create Dictionary    toothNo=${toothNo}  toothType=${toothType}  investigation=${investigation}  orginUid=${orginUid}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  provider/dental  data=${data}  expected_status=any
    [Return]  ${resp}

Update DentalRecord Status

    [Arguments]    ${healthRecordSectionEnum}   ${medicalId}  
    ${resp}=    PUT On Session    ynw   /provider/dental/${healthRecordSectionEnum}/${medicalId}        expected_status=any
    [Return]  ${resp}

Delete DentalRecord

    [Arguments]    ${Id}  
    ${resp}=    DELETE On Session    ynw    /provider/dental/${Id}       expected_status=any
    [Return]  ${resp}

Get DentalRecord ById

    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw    /provider/dental/${Id}        expected_status=any
    [Return]  ${resp}

Get DentalRecord ByProviderConsumerId

    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw    /provider/dental/providerconsumer/${Id}        expected_status=any
    [Return]  ${resp}

Get DentalRecord ByCaseId

    [Arguments]     ${Id}  
    ${resp}=    GET On Session    ynw   /provider/dental/mr/${Id}    expected_status=any
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
