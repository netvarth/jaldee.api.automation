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
Library           /ebs/TDD/CustomKeywords.py
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


JD-TC-UpdateBadge-1

    [Documentation]   update badge without passing id

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
    Should Be Equal As Strings      ${resp.json()['badges'][0]['name']}                         ${name2}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['link']}                         ${name2}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['name']}                         ${name3}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['link']}                         ${name3}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['attachments'][0]['driveId']}                 ${driveId}

JD-TC-UpdateBadge-2

    [Documentation]   update badge  passing id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${name1}=  FakerLibrary.last_name
    ${badges3}=  Create Dictionary   attachments=${attachments}  name=${name4}   link=${name1}  id=${badgeid2}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    Should Be Equal As Strings      ${resp.json()['badges'][1]['name']}                         ${name4}
    Should Be Equal As Strings      ${resp.json()['badges'][1]['link']}                         ${name1}

JD-TC-UpdateBadge-3

    [Documentation]   update badge with name  passing id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${badges3}=  Create Dictionary     name=${name4}     id=${badgeid1}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}    badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    Should Be Equal As Strings      ${resp.json()['badges'][0]['name']}                         ${name4}

JD-TC-UpdateBadge-4

    [Documentation]   update badge with link  passing id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=  FakerLibrary.first_name
    ${badges3}=  Create Dictionary     link=${name4}     id=${badgeid1}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}      badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['badges'][0]['link']}                         ${name4}

JD-TC-UpdateBadge-5

    [Documentation]   update badge with attachment  

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # .... Attachments ......

    ${resp}=  db.getType   ${pngfile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pngfile} 
    Set Test Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Test Variable    ${caption}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${pngfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  fileName=${pngfile}  fileSize=${fileSize}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    ${attachments}=  Create List   ${attachments}
    Set Test Variable    ${attachments}

    ${name4}=  FakerLibrary.first_name
    ${badges3}=  Create Dictionary    attachments=${attachments}  name=${name4}   link=${name3}
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge    ${item}     badges=${badges3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable      ${badgeid3}  ${resp.json()['badges'][2]['id']}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['name']}                         ${name4}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['link']}                         ${name3}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['fileName']}                ${pngfile}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['badges'][2]['attachments'][0]['driveId']}                 ${driveId}


JD-TC-UpdateBadge-6

    [Documentation]   update badge with empty attachment  

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${attachments}=  Create List   

    ${badges3}=  Create Dictionary    attachments=${attachments}  
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}     badges=${badges3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['badges'][3]['attachments']}                        []

JD-TC-UpdateBadge-UH1

    [Documentation]   update badge without login

    ${attachments}=  Create List   

    ${badges3}=  Create Dictionary    attachments=${attachments}  
    ${badges3}=  Create List   ${badges3}

    ${resp}=    UpdateBadge  ${item}     badges=${badges3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"


