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

JD-TC-Get_CRM_Lead_By_Filter-1

    [Documentation]   Get Crm Lead By Filter 

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

    ${resp}=    Create Crm Lead  ${clid}  ${firstName_n}  ${con_id}  ${lastName_n}  ${pid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    Set Test variable           ${crm_lead_id}          ${resp.json()}

    ${resp}=    Get Crm Lead By Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-2

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      id-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-3

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      account-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-4

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      createdDate-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-5

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      uid-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-6

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      referenceNo-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-7

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productType-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-8

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productEnum-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-9

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-10

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      productUid-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-11

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channel-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-12

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelType-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-13

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-14

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      channelUid-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-15

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerUid-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-16

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerFirstName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-17

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerLastName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-18

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerDob-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-19

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerGender-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-20

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCountryCode-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-21

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerPhone-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-22

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerEmail-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-23

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCity-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-24

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerState-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-25

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerCountry-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-26

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      consumerPin-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-27

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      assignees-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-28

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      remark-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-29

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      internalStatus-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200


JD-TC-Get_CRM_Lead_By_Filter-30

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      isRejected-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-31

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedBy-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-32

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedByName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-33

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      rejectedDate-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-34

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      isConverted-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-35

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedBy-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-36

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedByName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-37

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      convertedDate-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-38

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      ownerId-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-39

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      ownerName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-40

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      createdByName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-41

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      updatedByName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-42

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      location-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-43

    [Documentation]   Get Crm Lead By Filter - 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Crm Lead By Filter      locationName-eq=${}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

JD-TC-Get_CRM_Lead_By_Filter-44

    [Documentation]   Get Crm Lead By Filter - without login

    ${resp}=    Get Crm Lead By Filter      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
