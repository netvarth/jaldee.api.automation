*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0


*** Test Cases ***


JD-TC-RemoveBadge-1

    [Documentation]   create two badge and remove  badge

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    # .... Attachments ......

    ${resp}=  db.getType   ${jpgfile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  fileName=${jpgfile}  fileSize=${fileSize}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    ${attachments}=  Create List   ${attachments}
    Set Suite Variable    ${attachments}


    ${name2}=            FakerLibrary.name
    ${shortDesc2}=       FakerLibrary.sentence

    ${badges}=  Create Dictionary  attachments=${attachments}   name=${name2}   link=${name2}
    ${badges1}=  Create List   ${badges}

    ${resp}=    Create Item Inventory  ${name2}    badges=${badges1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200



    ${name3}=  FakerLibrary.first_name
    Set Suite Variable    ${name3}
    ${badges3}=  Create Dictionary  attachments=${attachments}   name=${name3}   link=${name3}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable      ${badgeid2}  ${resp.json()['badges'][1]['id']}
    Set Suite Variable      ${badgeid1}  ${resp.json()['badges'][0]['id']}


    ${badges3}=  Create Dictionary     id=${badgeid2}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    Remove Badge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()['badges']}
    Should Be Equal As Integers  ${len}  1


JD-TC-RemoveBadge-UH1

    [Documentation]   remove badge  thats already removed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${name1}=  FakerLibrary.last_name
    ${badges3}=  Create Dictionary    id=${badgeid2}
    ${badges3}=  Create List   ${badges3}


    ${BADGE_ID_NOT_FOUND}=  Format String  ${BADGE_ID_NOT_FOUND}    ${badgeid2}

    ${resp}=    Remove Badge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${BADGE_ID_NOT_FOUND}




JD-TC-RemoveBadge-UH2

    [Documentation]   try to update removed badge and then remove that again

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${badges3}=  Create Dictionary     name=${name4}     id=${badgeid2}
    ${badges3}=  Create List   ${badges3}

    ${BADGE_ID_NOT_FOUND}=  Format String  ${BADGE_ID_NOT_FOUND}    ${badgeid2}
    ${resp}=    UpdateBadge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${BADGE_ID_NOT_FOUND}

    ${resp}=    Remove Badge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${BADGE_ID_NOT_FOUND}

JD-TC-RemoveBadge-UH3

    [Documentation]   remove badge  without passing id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${badges3}=  Create Dictionary     link=${name4}   
    ${badges3}=  Create List   ${badges3}

    ${BADGE_ID_MUST_GREATER_THAN_ZERO}=  Format String  ${BADGE_ID_MUST_GREATER_THAN_ZERO}    0
    ${resp}=     Remove Badge  ${item}      badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${BADGE_ID_MUST_GREATER_THAN_ZERO}



JD-TC-RemoveBadge-UH4

    [Documentation]   remove badge without login

    ${attachments}=  Create List   

    ${badges3}=  Create Dictionary    attachments=${attachments}  
    ${badges3}=  Create List   ${badges3}

    ${resp}=    Remove Badge  ${item}     badges=${badges3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"


