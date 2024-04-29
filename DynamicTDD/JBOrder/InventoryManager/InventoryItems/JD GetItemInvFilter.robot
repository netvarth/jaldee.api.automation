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
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${fileSize}     0.00458
${order}        0
*** Test Cases ***

JD-TC-GetItemInvFilter-1

    [Documentation]   Get Item Inv Filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .... Create Hsn .....

    ${hsnCode}=                 Random Int  min=1  max=999
    Set Suite Variable          ${hsnCode}

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    # .... Create Jrx Item ......

    ${itemName}=        FakerLibrary.name
    ${description}=     FakerLibrary.sentence
    ${sku}=             FakerLibrary.name
    Set Suite Variable  ${itemName}
    Set Suite Variable  ${description}
    Set Suite Variable  ${sku}

    ${hsn}=     Create Dictionary    hsnCode=${hsnCode}

    ${resp}=    Create Item Jrx   ${itemName}  description=${description}  sku=${sku}  hsnCode=${hsn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable     ${itemjrx}   ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME23}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    # ...... Create Category .......

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${categoryCode}     ${resp.json()}

    # ...... Create Type .........

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Item Type   ${TypeName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${typeCode}     ${resp.json()}

    # ..... Create manufacturer .....

    ${manufactureName}=    FakerLibrary.name
    Set Suite Variable  ${manufactureName}

    ${resp}=  Create Item Manufacture   ${manufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${manufacturerCode}     ${resp.json()}

    # .... Cretate Group 01 ........

    ${groupName}=    FakerLibrary.name
    Set Suite Variable      ${groupName}

    ${groupDesc}=    FakerLibrary.name
    Set Suite Variable  ${groupDesc}

    ${groupCode}=   FakerLibrary.Sentence   nb_words=3
    Set Suite Variable  ${groupCode}

    ${resp}=    Create Item group Provider  ${groupName}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${ig_id}   ${resp.json()}

    # .... Cretate Group 02 ........

    ${groupName2}=    FakerLibrary.name
    Set Suite Variable      ${groupName2}

    ${groupDesc2}=    FakerLibrary.name
    Set Suite Variable  ${groupDesc2}

    ${groupCode2}=   FakerLibrary.Sentence   nb_words=3
    Set Suite Variable  ${groupCode2}

    ${resp}=    Create Item group Provider  ${groupName2}  ${groupCode2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${ig_id2}   ${resp.json()}

    ${itemGroups}=  Create List  ${ig_id}  ${ig_id2}

    # ..... Create Tax ......

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${cgst}=     Random Int  min=0  max=200
    ${sgst}=     Random Int  min=0  max=200
    ${igst}=     Random Int  min=0  max=200
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}
    Set Suite Variable      ${igst}

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  ${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}

    ${tax}=     Create List  ${itemtax_id}

    # ....... Create composition ......

    ${compositionName}=     FakerLibrary.name
    Set Suite Variable  ${compositionName}

    ${resp}=    Create Item Composition     ${compositionName} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${compositionCode}    ${resp.json()}

    ${composition}=     Create List  ${compositionCode}

    # ... Create itemUnits ....

    ${unitName}=          FakerLibrary.name
    ${convertionQty}=     Random Int  min=0  max=200
    Set Suite Variable      ${unitName}
    Set Suite Variable      ${convertionQty}

    ${resp}=    Create Item Unit  ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${iu_id}  ${resp.json()}

    ${itemUnits}=   Create List  ${iu_id}

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

    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    Set Suite Variable  ${name}
    Set Suite Variable  ${shortDesc}
    Set Suite Variable  ${internalDesc}

    ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[0]}  isInventoryItem=${boolean[0]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemCode']}                  ${itemjrx}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemName']}                  ${itemName}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['description']}               ${description}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['sku']}                       ${sku}
    Should Be Equal As Strings      ${resp.json()['name']}                                      ${name}
    Should Be Equal As Strings      ${resp.json()['shortDesc']}                                 ${shortDesc}
    Should Be Equal As Strings      ${resp.json()['internalDesc']}                              ${internalDesc}
    Should Be Equal As Strings      ${resp.json()['isInventoryItem']}                           ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['categoryCode']}              ${categoryCode}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['categoryName']}              ${categoryName}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['status']}                    ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['categoryCode']}           ${categoryCode}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['categoryName']}           ${categoryName}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['status']}                 ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemType']['typeCode']}                      ${typeCode}
    Should Be Equal As Strings      ${resp.json()['itemType']['typeName']}                      ${TypeName}
    Should Be Equal As Strings      ${resp.json()['itemType']['status']}                        ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemSubType']['typeCode']}                   ${typeCode}
    Should Be Equal As Strings      ${resp.json()['itemSubType']['typeName']}                   ${TypeName}
    Should Be Equal As Strings      ${resp.json()['itemSubType']['status']}                     ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemGroups'][0]}                             ${ig_id}
    Should Be Equal As Strings      ${resp.json()['itemGroups'][1]}                             ${ig_id2}
    Should Be Equal As Strings      ${resp.json()['itemSubGroups'][0]}                          ${ig_id}
    Should Be Equal As Strings      ${resp.json()['itemSubGroups'][1]}                          ${ig_id2}
    Should Be Equal As Strings      ${resp.json()['hsnCode']['hsnCode']}                        ${hsnCode}
    Should Be Equal As Strings      ${resp.json()['hsnCode']['status']}                         ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemManufacturer']['manufacturerCode']}      ${manufacturerCode}
    Should Be Equal As Strings      ${resp.json()['itemManufacturer']['manufacturerName']}      ${manufactureName}
    Should Be Equal As Strings      ${resp.json()['itemManufacturer']['status']}                ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['tax'][0]}                                    ${itemtax_id}
    Should Be Equal As Strings      ${resp.json()['composition'][0]}                            ${compositionCode}
    Should Be Equal As Strings      ${resp.json()['sku']}                                       ${sku}
    Should Be Equal As Strings      ${resp.json()['itemUnits'][0]}                              ${iu_id}
    Should Be Equal As Strings      ${resp.json()['isBatchApplicable']}                        ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${toggle[0]}

    ${resp}=    Get Item inv Filter
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['itemCode']}                  ${itemjrx}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['itemName']}                  ${itemName}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['description']}               ${description}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['sku']}                       ${sku}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                      ${name}
    Should Be Equal As Strings      ${resp.json()[0]['shortDesc']}                                 ${shortDesc}
    Should Be Equal As Strings      ${resp.json()[0]['internalDesc']}                              ${internalDesc}
    Should Be Equal As Strings      ${resp.json()[0]['isInventoryItem']}                           ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['categoryCode']}              ${categoryCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['categoryName']}              ${categoryName}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['status']}                    ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['categoryCode']}           ${categoryCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['categoryName']}           ${categoryName}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['status']}                 ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['typeCode']}                      ${typeCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['typeName']}                      ${TypeName}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['status']}                        ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['typeCode']}                   ${typeCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['typeName']}                   ${TypeName}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['status']}                     ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemGroups'][0]}                             ${ig_id}
    Should Be Equal As Strings      ${resp.json()[0]['itemGroups'][1]}                             ${ig_id2}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubGroups'][0]}                          ${ig_id}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubGroups'][1]}                          ${ig_id2}
    Should Be Equal As Strings      ${resp.json()[0]['hsnCode']['hsnCode']}                        ${hsnCode}
    Should Be Equal As Strings      ${resp.json()[0]['hsnCode']['status']}                         ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['manufacturerCode']}      ${manufacturerCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['manufacturerName']}      ${manufactureName}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['status']}                ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['tax'][0]}                                    ${itemtax_id}
    Should Be Equal As Strings      ${resp.json()[0]['composition'][0]}                            ${compositionCode}
    Should Be Equal As Strings      ${resp.json()[0]['sku']}                                       ${sku}
    Should Be Equal As Strings      ${resp.json()[0]['itemUnits'][0]}                              ${iu_id}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchApplicable']}                         ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()[0]['status']}                                    ${toggle[0]}


JD-TC-GetItemInvFilter-2

    [Documentation]   Get Item Inv Filter - status filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item inv Filter  status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['itemCode']}                  ${itemjrx}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['itemName']}                  ${itemName}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['description']}               ${description}
    Should Be Equal As Strings      ${resp.json()[0]['jaldeeRxCode']['sku']}                       ${sku}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                      ${name}
    Should Be Equal As Strings      ${resp.json()[0]['shortDesc']}                                 ${shortDesc}
    Should Be Equal As Strings      ${resp.json()[0]['internalDesc']}                              ${internalDesc}
    Should Be Equal As Strings      ${resp.json()[0]['isInventoryItem']}                           ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['categoryCode']}              ${categoryCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['categoryName']}              ${categoryName}
    Should Be Equal As Strings      ${resp.json()[0]['itemCategory']['status']}                    ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['categoryCode']}           ${categoryCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['categoryName']}           ${categoryName}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubCategory']['status']}                 ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['typeCode']}                      ${typeCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['typeName']}                      ${TypeName}
    Should Be Equal As Strings      ${resp.json()[0]['itemType']['status']}                        ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['typeCode']}                   ${typeCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['typeName']}                   ${TypeName}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubType']['status']}                     ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemGroups'][0]}                             ${ig_id}
    Should Be Equal As Strings      ${resp.json()[0]['itemGroups'][1]}                             ${ig_id2}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubGroups'][0]}                          ${ig_id}
    Should Be Equal As Strings      ${resp.json()[0]['itemSubGroups'][1]}                          ${ig_id2}
    Should Be Equal As Strings      ${resp.json()[0]['hsnCode']['hsnCode']}                        ${hsnCode}
    Should Be Equal As Strings      ${resp.json()[0]['hsnCode']['status']}                         ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['manufacturerCode']}      ${manufacturerCode}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['manufacturerName']}      ${manufactureName}
    Should Be Equal As Strings      ${resp.json()[0]['itemManufacturer']['status']}                ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()[0]['tax'][0]}                                    ${itemtax_id}
    Should Be Equal As Strings      ${resp.json()[0]['composition'][0]}                            ${compositionCode}
    Should Be Equal As Strings      ${resp.json()[0]['sku']}                                       ${sku}
    Should Be Equal As Strings      ${resp.json()[0]['itemUnits'][0]}                              ${iu_id}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchApplicable']}                         ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()[0]['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()[0]['status']}                                    ${toggle[0]}

JD-TC-GetItemInvFilter-3

    [Documentation]   Get Item Inv Filter - status filter

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item inv Filter  status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}      []

JD-TC-GetItemInvFilter-UH1

    [Documentation]   Get Item Inv Filter - without login

    ${resp}=    Get Item inv Filter
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemInvFilter-UH2

    [Documentation]   Get Item Inv - SA Login

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item inv Filter
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemInvFilter-UH3

    [Documentation]   Get Item Inv - another provider trying to get

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item inv Filter
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}      []