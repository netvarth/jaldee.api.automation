*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
${jpgfile}      /ebs/TDD/uploadimage.jpg
${fileSize}     0.00458
${order}        0

*** Test Cases ***

JD-TC-Create_Channel-1 

    [Documentation]   Create Channel - Valid Credentials with location and attachment

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${lid}      ${resp.json()[0]['id']}
    Set Suite Variable      ${place}    ${resp.json()[0]['place']}

    ${lid}=     Create Dictionary  id=${lid}
    ${loc_id}=  Create List   ${lid}

    ${typeName1}=    FakerLibrary.Name
    Set Suite Variable      ${typeName1}

    ${resp}=    Create Lead Product  ${typeName1}  ${productEnum[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200

    ${ChannelName1}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName1}
    
    ${crmLeadProductTypeDto}=   Create Dictionary   uid=${lpid}
    Set Suite Variable      ${crmLeadProductTypeDto}

    # .... Attachments ......

    ${resp}=            db.getType  ${jpgfile} 
    Log  ${resp}
    ${fileType}=                    Get From Dictionary       ${resp}    ${jpgfile} 
    Set Suite Variable              ${fileType}
    ${caption}=                     Fakerlibrary.Sentence
    Set Suite Variable              ${caption}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 
    Set Suite Variable              ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  fileName=${jpgfile}  fileSize=${fileSize}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    ${attachments}=  Create List    ${attachments}
    Set Suite Variable              ${attachments}

    ${resp}=    Create Lead Channel  ${ChannelName1}  ${leadchannel[0]}  ${crmLeadProductTypeDto}  locationDtos=${loc_id}  attachments=${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid}     ${resp.json()} 

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

JD-TC-Create_Channel-2

    [Documentation]   Create Channel - Valid Credentials

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ChannelName}=    FakerLibrary.Name

    ${resp}=    Create Lead Channel  ${ChannelName}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid_n}     ${resp.json()} 

JD-TC-Create_Product-3

    [Documentation]   Create Channel - where type name as number  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=  Random Int  min=100  max=10000

    ${resp}=    Create Lead Channel  ${name}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Product-4

    [Documentation]   Create Channel - where type name as alpha numeric

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=  Generate Random String    10    [NUMBERS] [LETTERS]

    ${resp}=    Create Lead Channel  ${name}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Product-5

    [Documentation]   Create Channel - where type name as alpha numeric

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ChannelName}=    FakerLibrary.Name

    ${resp}=    Create Lead Channel  ${ChannelName}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Product-6

    [Documentation]   Create Channel - where channel type is WHATSAPP

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ChannelName}=    FakerLibrary.Name

    ${resp}=    Create Lead Channel  ${ChannelName}  ${leadchannel[1]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Channel-UH1

    [Documentation]   Create Channel - where channel name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Lead Channel  ${empty}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      422
    Should Be Equal As Strings    ${resp.json()}    ${CHANNEL_NAME_SIZE}

JD-TC-Create_Product-UH2

    [Documentation]   Create Channel - where Lead Product Type Dto is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${ChannelName}=    FakerLibrary.Name
    ${crmLeadProductTypeDto2}=   Create Dictionary   uid=${inv}

    ${resp}=    Create Lead Channel  ${ChannelName}  ${leadchannel[1]}  ${crmLeadProductTypeDto2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PRODUCT_UID}

JD-TC-Create_Product-UH3

    [Documentation]   Create Channel - without login

    ${ChannelName}=    FakerLibrary.Name

    ${resp}=    Create Lead Channel  ${ChannelName}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Create_Product-UH4

    [Documentation]   Create Channel - channel name already exists

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Lead Channel  ${ChannelName1}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${CHANNEL_NAME_CANT_BE_SAME}


JD-TC-Create_Product-Uh5

    [Documentation]   Create Channel - where name is bellow 3 digit  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=  Generate Random String  2  [LETTERS]

    ${resp}=    Create Lead Channel  ${name}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CHANNEL_NAME_SIZE}

JD-TC-Create_Product-Uh6

    [Documentation]   Create Channel - where name is above 50 digit  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=  Generate Random String  101  [LETTERS]

    ${resp}=    Create Lead Channel  ${name}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CHANNEL_NAME_SIZE}

JD-TC-Create_Product-UH7

    [Documentation]   Create Channel - where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=    FakerLibrary.Name

    ${resp}=    Create Lead Channel  ${name}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CRM_LEAD_DISABLED}