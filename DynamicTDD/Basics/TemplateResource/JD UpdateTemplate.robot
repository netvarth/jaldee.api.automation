*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Template Config
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx
${self}         0

${templateHeader}     <d _ngcontent-ibc-c299=\"\" =\"shareview\" style=\"font-family: 'Figtree', sans-serif!important; padding: 10px;\"><div _ngcontent-ibc-c299=\"\" style=\"height: 35mm; margin-top: 30px;\"><div _ngcontent-ibc-c299=\"\" style=\"float: left; margin-right: 20px;\">
${templateContent}    <d _ngcontent-ibc-c299=\"\" =\"shareview\" style=\"font-family: 'Figtree', sans-serif!important; padding: 10px;\"><div _ngcontent-ibc-c299=\"\" style=\"height: 35mm; margin-top: 30px;\"><div _ngcontent-ibc-c299=\"\" style=\"float: left; margin-right: 20px;\">
${templateFooter}     <d _ngcontent-ibc-c299=\"\" =\"shareview\" style=\"font-family: 'Figtree', sans-serif!important; padding: 10px;\"><div _ngcontent-ibc-c299=\"\" style=\"height: 35mm; margin-top: 30px;\"><div _ngcontent-ibc-c299=\"\" style=\"float: left; margin-right: 20px;\">

@{printTemplateStatus}      active   inactive
@{printTemplateType}        Prescription    Case    Finance

*** Keywords ***
Create Template Config

    [Arguments]    ${templateName}  ${isDefaultTemp}  ${templateHeader}    ${templateContent}     ${templateFooter}  ${printTemplateStatus}  ${printTemplateType}

    ${data}=  Create Dictionary     templateName=${templateName}  isDefaultTemp=${isDefaultTemp}  templateHeader=${templateHeader}     templateContent=${templateContent}      templateFooter=${templateFooter}  printTemplateStatus=${printTemplateStatus}  printTemplateType=${printTemplateType}  
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/print/template  data=${data}   expected_status=any 
    RETURN  ${resp}

Update Template Config

    [Arguments]     ${uid}    ${templateName}  ${isDefaultTemp}  ${templateHeader}    ${templateContent}     ${templateFooter}  ${printTemplateStatus}  ${printTemplateType}

    ${data}=  Create Dictionary   templateName=${templateName}  isDefaultTemp=${isDefaultTemp}  templateHeader=${templateHeader}     templateContent=${templateContent}      templateFooter=${templateFooter}  printTemplateStatus=${printTemplateStatus}  printTemplateType=${printTemplateType}  
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/print/template/${uid}  data=${data}   expected_status=any 
    RETURN  ${resp}

Get Template By Uid

    [Arguments]    ${uid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/print/template/${uid}   expected_status=any
    RETURN  ${resp}

Get Templates By Account

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/print/template   expected_status=any
    RETURN  ${resp}

Get default domain templates

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/print/template/defaultDomainTemplates   expected_status=any
    RETURN  ${resp}

Get Account default template for the Type specified 

    [Arguments]    ${templateType}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/print/template/accountDefault/${templateType}   expected_status=any
    RETURN  ${resp}

Remove Template By Uid

    [Arguments]    ${uid}

    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/print/template/${uid}   expected_status=any
    RETURN  ${resp}


*** Test Cases ***

JD-TC-UpdateTemplateConfig-1

    [Documentation]  Create a Template with valid details and isDefaultTemp is true then update it's template name.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLMUSERNAME9}
    Set Suite Variable   ${p_id1}

    ${resp}=   Get Templates By Account
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}   []

    ${resp}=   Get default domain templates
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

    ${templateName1}=    FakerLibrary.name


    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}


JD-TC-UpdateTemplateConfig-2

    [Documentation]  Update that Template with Empty templateHeader.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName1}=    FakerLibrary.name

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${EMPTY}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

JD-TC-UpdateTemplateConfig-3

    [Documentation]  Update that Template with invalid templateHeader.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateHeader}=    FakerLibrary.Random Number
    ${templateName1}=    FakerLibrary.name


    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

JD-TC-UpdateTemplateConfig-4

    [Documentation]  Update that Template with Empty templateContent.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName1}=    FakerLibrary.name

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${EMPTY}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

JD-TC-UpdateTemplateConfig-5

    [Documentation]  Update that Template with Empty templateFooter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName1}=    FakerLibrary.name

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${EMPTY}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}


JD-TC-UpdateTemplateConfig-6

    [Documentation]  Update that Template with inactive printTemplateStatus.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName1}=    FakerLibrary.name

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

JD-TC-UpdateTemplateConfig-7

    [Documentation]  Update that Template with case printTemplateType.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName1}=    FakerLibrary.name
    Set Suite Variable  ${templateName1}

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[1]}
    Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}

JD-TC-UpdateTemplateConfig-8

    [Documentation]  create a new template with isDefaultTemp is false then Update first Template with isDefaultTemp is false,again upadate new template isDefaultTemp as true.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName3}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName3}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid2}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid2}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName3}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName1}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName1}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    # Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

    ${resp}=   Update Template Config   ${temp_uid2}   ${templateName3}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid2}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName3}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    # Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[1]}