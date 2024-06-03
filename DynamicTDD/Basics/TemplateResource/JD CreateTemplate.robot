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

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLPUSERNAME6}
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

JD-TC-CreateTemplateConfig-2

    [Documentation]  Try to Create another Template with isDefaultTemp is false.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid1}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

JD-TC-CreateTemplateConfig-3

    [Documentation]   Create Template with printTemplateType us case.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid1}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

JD-TC-CreateTemplateConfig-4

    [Documentation]   Create Template with printTemplateType as Finance.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid1}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[2]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

JD-TC-CreateTemplateConfig-5

    [Documentation]   Create Template with printTemplateStatus as inactive.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid1}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

JD-TC-CreateTemplateConfig-6

    [Documentation]   User Create a Template with isDefaultTemp is true.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${u_id}=  Create Sample User   admin=${bool[1]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[1]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${temp_uid1}  ${resp.json()['uid']}

    ${resp}=   Get Template By Uid      ${temp_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}   ${temp_uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${p_id1}
    Should Be Equal As Strings    ${resp.json()['templateName']}   ${templateName}
    Should Be Equal As Strings    ${resp.json()['templateHeader']}   ${templateHeader}
    Should Be Equal As Strings    ${resp.json()['templateContent']}   ${templateContent}
    Should Be Equal As Strings    ${resp.json()['templateFooter']}   ${templateFooter}
    Should Be Equal As Strings    ${resp.json()['printTemplateType']}   ${printTemplateType[0]}
    # Should Be Equal As Strings    ${resp.json()['printTemplateStatus']}   ${printTemplateStatus[1]}
    Should Be Equal As Strings    ${resp.json()['isDefaultTemp']}   ${bool[0]}

JD-TC-CreateTemplateConfig-UH1

    [Documentation]  Try to Create another Template with isDefaultTemp is true.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${ALREADY_HAVE_DEFAULT_TEMP}

JD-TC-CreateTemplateConfig-UH2

    [Documentation]  Try to Create another Template with EMPTY templateName.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${EMPTY}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NAME_REQUIRED}


JD-TC-CreateTemplateConfig-UH3

    [Documentation]  Try to Create another Template with EMPTY templateHeader.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${EMPTY}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMP_HEADER_REQUIRED}

JD-TC-CreateTemplateConfig-UH4

    [Documentation]  Try to Create another Template with EMPTY templateContent.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${EMPTY}   ${templateFooter}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMP_CONTENT_REQUIRED}

JD-TC-CreateTemplateConfig-UH5

    [Documentation]  Try to Create another Template with EMPTY templateFooter.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${EMPTY}   ${printTemplateStatus[0]}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMP_FOOTER_REQUIRED}

JD-TC-CreateTemplateConfig-UH6

    [Documentation]  Try to Create another Template with EMPTY printTemplateStatus.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${EMPTY}  ${printTemplateType[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMP_HEADER_REQUIRED}

JD-TC-CreateTemplateConfig-UH7

    [Documentation]  Try to Create another Template with EMPTY printTemplateType.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${templateName}=    FakerLibrary.name

    ${resp}=   Create Template Config   ${templateName}     ${bool[0]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus[0]}  ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${TEMP_HEADER_REQUIRED}


*** Comments ***

    ${resp}=   Update Template Config   ${temp_uid}   ${templateName}     ${bool[1]}      ${templateHeader}   ${templateContent}   ${templateFooter}   ${printTemplateStatus}  ${printTemplateType}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Templates By Account
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get default domain templates
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account default template for the Type specified      ${printTemplateType}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Remove Template By Uid   ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=   Get default domain templates
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Template By Uid      ${temp_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Templates By Account
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

