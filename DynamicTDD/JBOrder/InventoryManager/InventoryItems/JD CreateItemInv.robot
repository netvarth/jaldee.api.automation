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

JD-TC-CreateItemInv-1

    [Documentation]   Create Item Inv

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
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

    ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplication=${boolean[0]}  isInventoryItem=${boolean[0]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}
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
    Should Be Equal As Strings      ${resp.json()['isBatchApplication']}                        ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${toggle[0]}

JD-TC-CreateItemInv-2

    [Documentation]   Create Item Inv - with same item name 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Inventory  ${name}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${NAME_ALREADY_EXIST}  

JD-TC-CreateItemInv-3

    [Documentation]   Create Item Inv - name is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Inventory  ${empty}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-4

    [Documentation]   Create Item Inv - update short description

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${shortDesc2}=       FakerLibrary.sentence

    ${resp}=    Create Item Inventory  ${name2}    shortDesc=${shortDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-5

    [Documentation]   Create Item Inv - short description is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    shortDesc=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-6

    [Documentation]   Create Item Inv - update internal description

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${internalDesc2}=       FakerLibrary.sentence

    ${resp}=    Create Item Inventory  ${name2}    internalDesc=${internalDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-7

    [Documentation]   Create Item Inv - internal description is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    internalDesc=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-8

    [Documentation]   Create Item Inv - item code as random number

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=              Random Int  min=999    max=9999

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-9

    [Documentation]   Create Item Inv - item code is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-10

    [Documentation]   Create Item Inv - category code is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-11

    [Documentation]   Create Item Inv - category Code is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-12

    [Documentation]   Create Item Inv - Subcategory is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-13

    [Documentation]   Create Item Inv - Sub category is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-14

    [Documentation]   Create Item Inv - type is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-15

    [Documentation]   Create Item Inv - type is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-16

    [Documentation]   Create Item Inv - sub type is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    typeCode2=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-17

    [Documentation]   Create Item Inv - sub type is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    typeCode2=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-18

    [Documentation]   Create Item Inv - hsn is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    hsnCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-19

    [Documentation]   Create Item Inv - hsn is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    hsnCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-20

    [Documentation]   Create Item Inv - manufacturerCode is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    manufacturerCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-21

    [Documentation]   Create Item Inv - manufacturerCode is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    manufacturerCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-22

    [Documentation]   Create Item Inv - sku is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    sku=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-23

    [Documentation]   Create Item Inv - sku is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    sku=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-24

    [Documentation]   Create Item Inv - isBatchApplication is true

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    isBatchApplication=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-25

    [Documentation]   Create Item Inv - isInventoryItem is true

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    isInventoryItem=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-26

    [Documentation]   Create Item Inv - itemGroups is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    itemGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-27

    [Documentation]   Create Item Inv - itemGroups is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    itemGroups=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-28

    [Documentation]   Create Item Inv - itemSubGroups is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    itemSubGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-29

    [Documentation]   Create Item Inv - itemSubGroups is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    itemSubGroups=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-30

    [Documentation]   Create Item Inv - tax is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    tax=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-31

    [Documentation]   Create Item Inv - tax is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    tax=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-32

    [Documentation]   Create Item Inv - composition is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    composition=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-33

    [Documentation]   Create Item Inv - composition is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    composition=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-34

    [Documentation]   Create Item Inv - itemUnits is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    itemUnits=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-35

    [Documentation]   Create Item Inv - itemUnits is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    itemUnits=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-36

    [Documentation]   Create Item Inv - attachment is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    attachments=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 





















JD-TC-CreateItemInv-8

    [Documentation]   Create Item Inv - itemcode as random number

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=              Random Int  min=999    max=9999

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-10

    [Documentation]   Create Item Inv - category code is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-12

    [Documentation]   Create Item Inv - Subcategory is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-14

    [Documentation]   Create Item Inv - type is invalid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200