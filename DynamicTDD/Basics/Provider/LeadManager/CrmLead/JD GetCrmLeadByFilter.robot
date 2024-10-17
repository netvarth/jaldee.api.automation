*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
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

JD-TC-Get_CRM_Lead_By_Filter-1

    [Documentation]   Get Crm Lead By Filter 

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
    Set Suite Variable    ${product_id}      ${resp.json()['id']}

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
    Set Suite Variable    ${channel_id}      ${resp.json()['id']}

    ${firstName_n}=   FakerLibrary.firstName
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
    Should Be Equal As Strings  ${resp.status_code}                  200
    Set Suite Variable          ${id}                                ${resp.json()['id']}
    Set Suite Variable          ${referenceNo}                       ${resp.json()['referenceNo']}
    Should Be Equal As Strings  ${resp.json()['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()['channel']['id']}      ${channel_id}   
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
    Should Be Equal As Strings  ${resp.json()['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()['locationName']}       ${place}

    # second lead

    ${consumerFirstName}=   FakerLibrary.firstName
    ${consumerLastName}=    FakerLibrary.lastName
    ${dob}=  FakerLibrary.Date
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336845
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    Set Suite Variable  ${dob}
    Set Suite Variable      ${consumerFirstName}
    Set Suite Variable      ${consumerLastName}

    ${resp}=    Create Crm Lead  ${clid}  ${pid}  ${lid}  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}    gender=${Genderlist[0]}     countryCode=${countryCodes[0]}    phone=${PUSERNAME_U1}   address=${address}   email=${P_Email}${PUSERNAME_U1}.${test_mail}    city=${city}   state=${state}    country=${city}   pin=${postcode}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Set Suite variable           ${crm_lead_id2}          ${resp.json()}

    ${resp}=    Get Crm Lead   ${crm_lead_id2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                  200
    Set Suite Variable          ${id2}                               ${resp.json()['id']}
    Set Suite Variable          ${referenceNo2}                      ${resp.json()['referenceNo']}
    Should Be Equal As Strings  ${resp.json()['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()['locationName']}       ${place}

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id            ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Set Suite Variable  ${user1_id}     ${resp.json()['id']}
    Set Suite Variable  ${user_num}     ${resp.json()['mobileNo']}
    Set Suite Variable  ${firstName}    ${resp.json()['firstName']}
    Set Suite Variable  ${lastName}     ${resp.json()['lastName']}

    ${resp}=    Crm Lead Update Assign  ${crm_lead_id}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead By Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-2

    [Documentation]   Get Crm Lead By Filter - id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-3

    [Documentation]   Get Crm Lead By Filter - account

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      account-eq=${accountId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-4

    [Documentation]   Get Crm Lead By Filter - created date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      createdDate-eq=${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-5

    [Documentation]   Get Crm Lead By Filter - uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      uid-eq=${crm_lead_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-6

    [Documentation]   Get Crm Lead By Filter -  reference No

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      referenceNo-eq=${referenceNo2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-7

    [Documentation]   Get Crm Lead By Filter - product type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productType-eq=${product_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-8

    [Documentation]   Get Crm Lead By Filter - product Enum

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productEnum-eq=${productEnum[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-9

    [Documentation]   Get Crm Lead By Filter - product Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productName-eq=${typeName1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-10

    [Documentation]   Get Crm Lead By Filter - product Uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productUid-eq=${lpid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-11

    [Documentation]   Get Crm Lead By Filter - channel

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channel-eq=${channel_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-12

    [Documentation]   Get Crm Lead By Filter - channel Type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelType-eq=${leadchannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-13

    [Documentation]   Get Crm Lead By Filter - channel Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelName-eq=${ChannelName1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-14

    [Documentation]   Get Crm Lead By Filter - channel Uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelUid-eq=${clid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-15

    [Documentation]   Get Crm Lead By Filter - consumer Uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerUid-eq=${con_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-16

    [Documentation]   Get Crm Lead By Filter - consumer FirstName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerFirstName-eq=${consumerFirstName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-17

    [Documentation]   Get Crm Lead By Filter - consumer LastName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerLastName-eq=${consumerLastName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-18

    [Documentation]   Get Crm Lead By Filter - consumer Dob

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerDob-eq=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-19

    [Documentation]   Get Crm Lead By Filter - consumer gender

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerGender-eq=${Genderlist[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-20

    [Documentation]   Get Crm Lead By Filter - consumer country code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCountryCode-eq=${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-21

    [Documentation]   Get Crm Lead By Filter - consumer Phone

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerPhone-eq=${PUSERNAME_U1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-22

    [Documentation]   Get Crm Lead By Filter - consumer email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerEmail-eq=${P_Email}${PUSERNAME_U1}.${test_mail}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-23

    [Documentation]   Get Crm Lead By Filter - consumer city

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCity-eq=${city}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-24

    [Documentation]   Get Crm Lead By Filter - consumer state

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerState-eq=${state}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-25

    [Documentation]   Get Crm Lead By Filter - consumer country

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCountry-eq=${city}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-26

    [Documentation]   Get Crm Lead By Filter - consumer pin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerPin-eq=${postcode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-27

    [Documentation]   Get Crm Lead By Filter - assignees

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      assignees-eq=${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

# JD-TC-Get_CRM_Lead_By_Filter-28

#     [Documentation]   Get Crm Lead By Filter - 

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Get Crm Lead By Filter      remark-eq=${}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}     200
#     Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
#     Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
#     Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
#     Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
#     Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
#     Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
#     Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
#     Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
#     Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
#     Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
#     Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
#     Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
#     Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
#     Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
#     Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
#     Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
#     Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
#     Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
#     Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
#     Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
#     Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
#     Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
#     Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
#     Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
#     Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
#     Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
#     Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
#     Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
#     Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
#     Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
#     Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
#     Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
#     Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
#     Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
#     Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-29

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      internalStatus-eq=${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-31

    [Documentation]   Get Crm Lead By Filter - rejected By

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedBy-eq=${accountId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-32

    [Documentation]   Get Crm Lead By Filter - rejected By Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedByName-eq=${pdrname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-33

    [Documentation]   Get Crm Lead By Filter - rejected Date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedDate-eq=${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-35

    [Documentation]   Get Crm Lead By Filter - converted By

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedBy-eq=${accountId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-36

    [Documentation]   Get Crm Lead By Filter - converted By Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedByName-eq=${pdrname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-37

    [Documentation]   Get Crm Lead By Filter - converted Date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedDate-eq=${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-38

    [Documentation]   Get Crm Lead By Filter - owner id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      ownerId-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-39

    [Documentation]   Get Crm Lead By Filter - owner Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      ownerName-eq=${pdrname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-40

    [Documentation]   Get Crm Lead By Filter - created By Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      createdByName-eq=${pdrname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-41

    [Documentation]   Get Crm Lead By Filter - location id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      location-eq=${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-42

    [Documentation]   Get Crm Lead By Filter - location name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      locationName-eq=${place}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()[0]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[0]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${crm_lead_id2}
    Should Be Equal As Strings  ${resp.json()[0]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[0]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[0]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[0]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[0]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[0]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[0]['consumerFirstName']}  ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()[0]['consumerLastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()[0]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['locationName']}       ${place}
    Should Be Equal As Strings  ${resp.json()[1]['productType']['id']}  ${product_id}
    Should Be Equal As Strings  ${resp.json()[1]['channel']['id']}      ${channel_id}   
    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${crm_lead_id}
    Should Be Equal As Strings  ${resp.json()[1]['productEnum']}        ${productEnum[0]}
    Should Be Equal As Strings  ${resp.json()[1]['productName']}        ${typeName1}
    Should Be Equal As Strings  ${resp.json()[1]['productUid']}         ${lpid}
    Should Be Equal As Strings  ${resp.json()[1]['channelType']}        ${leadchannel[0]}
    Should Be Equal As Strings  ${resp.json()[1]['channelName']}        ${ChannelName1}
    Should Be Equal As Strings  ${resp.json()[1]['channelUid']}         ${clid}
    Should Be Equal As Strings  ${resp.json()[1]['consumerFirstName']}  ${firstName_n}
    Should Be Equal As Strings  ${resp.json()[1]['consumerLastName']}   ${lastName_n}
    Should Be Equal As Strings  ${resp.json()[1]['internalStatus']}     ${status[0]}
    Should Be Equal As Strings  ${resp.json()[1]['ownerId']}            ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['ownerName']}          ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdBy']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[1]['createdByName']}      ${pdrname}
    Should Be Equal As Strings  ${resp.json()[1]['createdDate']}        ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['location']}           ${lid}
    Should Be Equal As Strings  ${resp.json()[1]['locationName']}       ${place}

JD-TC-Get_CRM_Lead_By_Filter-43

    [Documentation]   Get Crm Lead By Filter - without login

    ${resp}=    Get Crm Lead By Filter      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings  ${resp.json()}          ${SESSION_EXPIRED}
