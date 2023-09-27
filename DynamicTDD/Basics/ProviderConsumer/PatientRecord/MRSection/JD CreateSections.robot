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

*** Keywords  ***

Create Sections 
    [Arguments]    ${mrCase}    ${doctor}    ${templateDetailId}       ${sectionType}    ${sectionValue}    ${attachments}     &{kwargs}
    ${data}=    Create Dictionary    mrCase=${mrCase}    doctor=${doctor}    templateDetailId=${templateDetailId}      sectionType=${sectionType}    sectionValue=${sectionValue}    attachments=${attachments}    voiceAttachments=${voiceAttachments}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw    /provider/medicalrecord/section    data=${data}    expected_status=any
    [Return]  ${resp}

Update MR Sections
    [Arguments]    ${uid}   ${sectionValue}   ${attachments}     &{kwargs}
    ${data}=    Create Dictionary    sectionValue=${sectionValue}    attachments=${attachments}    voiceAttachments=${voiceAttachments}      
    Check And Create YNW Session
    $FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}
    ${resp}=    PUT On Session    ynw    /provider/medicalrecord/section/${uid}   data=${data}    expected_status=any
    [Return]  ${resp}

Get Section Template
    [Arguments]    ${caseUid} 
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/template/case/${caseUid}    expected_status=any
    [Return]  ${resp}

Get Sections By UID
    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/${uid}    expected_status=any
    [Return]  ${resp}

Get Sections Filter
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section    expected_status=any
    [Return]  ${resp}

Get MR Sections By Case
    [Arguments]    ${uid}
    Check And Create YNW Session
    ${resp}=    GET On Session    ynw   /provider/medicalrecord/section/case/${uid}    expected_status=any
    [Return]  ${resp}

Delete MR Sections 
    Check And Create YNW Session
    [Arguments]    ${uid} 
    ${resp}=    DELETE On Session    ynw    /provider/medicalrecord/section/${uid}       expected_status=any
    [Return]  ${resp}


*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${titles}    @sdf@123
${description1}    &^7gsdkqwrrf