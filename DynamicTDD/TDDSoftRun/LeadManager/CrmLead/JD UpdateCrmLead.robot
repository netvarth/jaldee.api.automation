*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
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
${fileSize}     0.00458
${order}        0

*** Test Cases ***

JD-TC-Update_Lead-1

    [Documentation]   Update lead - updating same firstname and lastname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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

    ${locid}=     Create Dictionary  id=${lid}
    ${loc_id}=  Create List   ${locid}

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

    ${firstName_n}=   generate_firstname
    ${lastName_n}=    FakerLibrary.lastName
    Set Suite Variable      ${firstName_n}
    Set Suite Variable      ${lastName_n}

    ${resp}=    Create Lead Consumer  ${firstName_n}  ${lastName_n}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite variable   ${con_id}   ${resp.json()}

    ${resp}=    Get Lead Consumer  ${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}             200

    ${resp}=    Create Crm Lead  ${clid}  ${pid}  ${lid}  consumerUid=${con_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Set Suite variable           ${crm_lead_id}          ${resp.json()}

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdDate']}        ${DAY1}

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${firstName_n}  ${lastName_n}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdDate']}        ${DAY1}

JD-TC-Update_Lead-2

    [Documentation]   Update lead - update firstname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName2}=   generate_firstname

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${firstName2}  ${lastName_n} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()['consumerFirstName']}  ${firstName2}
    Should Be Equal As Strings  ${resp.json()['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdDate']}        ${DAY1}

JD-TC-Update_Lead-3

    [Documentation]   Update lead - update lastname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lastName2}=   generate_firstname

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${firstName_n}  ${lastName2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()['consumerLastName']}   ${lastName2}
    Should Be Equal As Strings  ${resp.json()['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdDate']}        ${DAY1}

JD-TC-Update_Lead-UH1

    [Documentation]   Update lead - firstname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_CANT_BE_EMPTY}=   Replace String  ${FIELD_CANT_BE_EMPTY}  {}   first name

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${NULL}  ${lastName_n} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${FIELD_CANT_BE_EMPTY}

JD-TC-Update_Lead-UH2

    [Documentation]   Update lead - lastname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_CANT_BE_EMPTY}=   Replace String  ${FIELD_CANT_BE_EMPTY}  {}   last name

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${firstName_n}  ${NULL} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${FIELD_CANT_BE_EMPTY}

JD-TC-Update_Lead-UH3

    [Documentation]   Update lead - firstname and lastname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_CANT_BE_EMPTY}=   Replace String  ${FIELD_CANT_BE_EMPTY}  {}   first name

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${NULL}  ${NULL} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${FIELD_CANT_BE_EMPTY}

JD-TC-Update_Lead-UH4

    [Documentation]   Update lead - uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${INVALID_Y_ID}=   Replace String  ${INVALID_Y_ID}  {}   Lead

    ${resp}=    Update Crm Lead  ${inv}  ${firstName_n}  ${lastName_n} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${INVALID_Y_ID}

JD-TC-Update_Lead-UH5

    [Documentation]   Update lead - without login

    ${resp}=    Update Crm Lead  ${crm_lead_id}  ${firstName_n}  ${lastName_n} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings  ${resp.json()}          ${SESSION_EXPIRED}
