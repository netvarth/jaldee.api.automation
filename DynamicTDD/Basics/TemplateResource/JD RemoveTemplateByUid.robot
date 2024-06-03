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
Variables         /ebs/TDD/varfiles/hl_providers.py

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


*** Test Cases ***

JD-TC-CreateTemplateConfig-1

    [Documentation]  provide login account then try to get Get Templates By Account,Then Create a Template with valid details.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLPUSERNAME4}
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

    ${resp}=   Get Templates By Account
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}   ${temp_uid}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()[0]['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()[0]['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()[0]['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()[0]['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()[0]['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['isDefaultTemp']}   ${bool[1]}

    ${resp}=   Remove Template By Uid   ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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