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

JD-TC-Unassign_User_To_Crm_Lead-1

    [Documentation]   Unassign User To Crm Lead 

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

    ${firstName_n}=   FakerLibrary.firstName
    ${lastName_n}=    FakerLibrary.lastName
    Set Suite Variable      ${firstName_n}
    Set Suite Variable      ${lastName_n}

    ${resp}=    Create Lead Consumer  ${firstName_n}  ${lastName_n}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test variable   ${con_id}   ${resp.json()}

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

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id            ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Set Suite Variable  ${user1_id}     ${resp.json()['id']}
    Set Suite Variable  ${user_num}     ${resp.json()['mobileNo']}

    ${resp}=    Crm Lead Update Assign  ${crm_lead_id}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Crm Lead Update Unassign  ${crm_lead_id}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=    Get Crm Lead   ${crm_lead_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Unassign_User_To_Crm_Lead-2

    [Documentation]   Unassign User To Crm Lead - Unassign the same user again

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Crm Lead Update Unassign  ${crm_lead_id}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Unassign_User_To_Crm_Lead-3

    [Documentation]   Unassign User To Crm Lead - where lead id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}  Random int  min=1  max=999

    ${INVALID_Y_ID}=   Replace String  ${INVALID_Y_ID}  {}   Lead

    ${resp}=    Crm Lead Update Unassign  ${inv}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422
    Should Be Equal As Strings  ${resp.json()}          ${INVALID_Y_ID}


JD-TC-Unassign_User_To_Crm_Lead-4

    [Documentation]   Unassign User To Crm Lead - where user id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}  Random int  min=1  max=999

    ${resp}=    Crm Lead Update Unassign  ${crm_lead_id}  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     422

JD-TC-Unassign_User_To_Crm_Lead-5

    [Documentation]   Unassign User To Crm Lead - without login

    ${resp}=    Crm Lead Update Unassign  ${crm_lead_id}  ${user1_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings  ${resp.json()}          ${SESSION_EXPIRED}

