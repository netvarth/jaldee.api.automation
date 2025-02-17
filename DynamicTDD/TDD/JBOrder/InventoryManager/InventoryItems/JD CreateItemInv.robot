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

JD-TC-CreateItemInv-1

    [Documentation]   Create Item Inv

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
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
    ${taxPercentage}=           Convert To Number  ${taxPercentage}  1
    ${cgst}=     Evaluate   ${taxPercentage} / 2
    ${sgst}=     Evaluate   ${taxPercentage} / 2
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}


    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
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
    # ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[0]}  isInventoryItem=${boolean[0]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  
    ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[0]}  isInventoryItem=${boolean[0]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
 

JD-TC-CreateItemInv-2

    [Documentation]   Create Item Inv - name is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}  Name is 
    ${resp}=    Create Item Inventory  ${empty}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FIELD_REQUIRED}


JD-TC-CreateItemInv-3

    [Documentation]   Create Item Inv - update short description

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${shortDesc2}=       FakerLibrary.sentence

    ${resp}=    Create Item Inventory  ${name2}    shortDesc=${shortDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-4

    [Documentation]   Create Item Inv - short description is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    shortDesc=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-5

    [Documentation]   Create Item Inv - update internal description

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${internalDesc2}=       FakerLibrary.sentence

    ${resp}=    Create Item Inventory  ${name2}    internalDesc=${internalDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-6

    [Documentation]   Create Item Inv - internal description is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    internalDesc=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-7

    [Documentation]   Create Item Inv - sku is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${resp}=    Create Item Inventory  ${name2}    sku=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-8

    [Documentation]   Create Item Inv - sku is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    sku=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-9

    [Documentation]   Create Item Inv - isBatchApplicable is true

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    isBatchApplicable=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${BATCH_APPLICABLE_SECLECT_ONLY_FOR_INVENTORY_ITEMS} 
    


JD-TC-CreateItemInv-10

    [Documentation]   Create Item Inv - isInventoryItem is true

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    isInventoryItem=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-11

    [Documentation]   Create Item Inv - itemGroups is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=  Create List  

    ${resp}=    Create Item Inventory  ${name2}    itemGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-12

    [Documentation]   Create Item Inv - itemSubGroups is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=  Create List 

    ${resp}=    Create Item Inventory  ${name2}    itemSubGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-13

    [Documentation]   Create Item Inv - tax is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=  Create List  

    ${resp}=    Create Item Inventory  ${name2}    tax=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-14

    [Documentation]   Create Item Inv - composition is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=  Create List 

    ${resp}=    Create Item Inventory  ${name2}    composition=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-15

    [Documentation]   Create Item Inv - itemUnits is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${inv}=  Create List  

    ${resp}=    Create Item Inventory  ${name2}    itemUnits=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-16

    [Documentation]   Create Item Inv - attachment is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${inv}=  Create List  

    ${resp}=    Create Item Inventory  ${name2}    attachments=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 


JD-TC-CreateItemInv-17

    [Documentation]   Create Item Inv - update item code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .... Create Hsn .....

    ${hsnCode2}=                 Random Int  min=1  max=999
    Set Suite Variable          ${hsnCode2}

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id2}      ${resp.json()}

    # .... Create Jrx Item ......

    ${itemName2}=        FakerLibrary.name
    ${description2}=     FakerLibrary.sentence
    ${sku2}=             FakerLibrary.name
    Set Suite Variable  ${itemName2}
    Set Suite Variable  ${description2}
    Set Suite Variable  ${sku2}

    ${hsn2}=     Create Dictionary    hsnCode=${hsnCode2}

    ${resp}=    Create Item Jrx   ${itemName2}  description=${description2}  sku=${sku2}  hsnCode=${hsn2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable     ${itemjrx2}   ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${itemjrx2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-18

    [Documentation]   Create Item Inv - Created with category code

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${categoryName2}=    FakerLibrary.name
    Set Suite Variable  ${categoryName2}

    ${resp}=  Create Item Category   ${categoryName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${categoryCode2}     ${resp.json()}

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${categoryCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-19

    [Documentation]   Create Item Inv -Created with Subcategory

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${categoryCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-20

    [Documentation]   Create Item Inv - Created with type

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Item Type   ${TypeName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${typeCode2}     ${resp.json()}

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${typeCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-21

    [Documentation]   Create Item Inv - Created with sub type

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    typeCode2=${typeCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-22

    [Documentation]   Create Item Inv - Created with hsn

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    hsnCode=${hsnCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-23

    [Documentation]   Create Item Inv - Created with manufacturerCode

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${manufactureName2}=    FakerLibrary.name
    Set Suite Variable  ${manufactureName2}

    ${resp}=  Create Item Manufacture   ${manufactureName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${manufacturerCode2}     ${resp.json()}

    ${resp}=    Create Item Inventory  ${name2}    manufacturerCode=${manufacturerCode2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-24

    [Documentation]   Create Item Inv - Created with sku 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2}    sku=${sku2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-25

    [Documentation]   Create Item Inv - Created with itemGroups

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${itemGroups2}=  Create List  ${ig_id}

    ${resp}=    Create Item Inventory  ${name2}    itemGroups=${itemGroups2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemInv-26

    [Documentation]   Create Item Inv - Created with itemSubGroups

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${itemGroups3}=  Create List  ${ig_id}

    ${resp}=    Create Item Inventory  ${name2}    itemSubGroups=${itemGroups3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-27

    [Documentation]   Create Item Inv - Created with tax

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name

    ${taxName2}=    FakerLibrary.name
    ${taxPercentage2}=     Random Int  min=0  max=200
    ${taxPercentage2}=           Convert To Number  ${taxPercentage}  1
    ${cgst2}=     Evaluate   ${taxPercentage} / 2
    ${sgst2}=     Evaluate   ${taxPercentage} / 2
    Set Suite Variable      ${taxName2}
    Set Suite Variable      ${taxPercentage2}
    Set Suite Variable      ${cgst2}
    Set Suite Variable      ${sgst2}

    ${resp}=    Create Item Tax  ${taxName2}  ${taxtypeenum[0]}  ${taxPercentage2}  ${cgst2}  ${sgst2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id2}  ${resp.json()}

    ${tax2}=     Create List  ${itemtax_id2}

    ${resp}=    Create Item Inventory  ${name2}    tax=${tax2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-28

    [Documentation]   Create Item Inv - Created with composition

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    
    ${compositionName2}=     FakerLibrary.name
    Set Suite Variable  ${compositionName2}

    ${resp}=    Create Item Composition     ${compositionName2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${compositionCode2}    ${resp.json()}

    ${composition2}=     Create List  ${compositionCode2}

    ${resp}=    Create Item Inventory  ${name2}    composition=${composition2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-29

    [Documentation]   Create Item Inv - Created with itemUnits

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    
    ${unitName2}=          FakerLibrary.name
    ${convertionQty2}=     Random Int  min=0  max=200
    Set Suite Variable      ${unitName2}
    Set Suite Variable      ${convertionQty2}

    ${resp}=    Create Item Unit  ${unitName2}  ${convertionQty2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${iu_id2}  ${resp.json()}

    ${itemUnits2}=   Create List  ${iu_id2}

    ${resp}=    Create Item Inventory  ${name2}    itemUnits=${itemUnits2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateItemInv-30

    [Documentation]   Create Item Inv -Created with attachment

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${resp}=  db.getType   ${pngfile} 
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile} 
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${pngfile}    ${fileSize}    ${caption2}    ${fileType2}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId2}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachments2}=    Create Dictionary   action=${file_action[0]}  fileName=${pngfile}  fileSize=${fileSize}  fileType=${fileType2}  order=${order}    driveId=${driveId2}
    Log  ${attachments2}
    ${attachments2}=  Create List   ${attachments2}
    Set Suite Variable    ${attachments2}

    ${resp}=    Create Item Inventory  ${name2}    attachments=${attachments2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 


JD-TC-CreateItemInv-UH1

    [Documentation]   Create Item Inv - with same item name 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Item Inventory  ${name}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${NAME_ALREADY_EXIST} 

JD-TC-CreateItemInv-UH2

    [Documentation]   Create Item Inv - item code as random number

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${inv}=              Random Int  min=999    max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Jaldee${space}${space}Id name${space} 

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-Uh3

    [Documentation]   Create Item Inv - item code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Jaldee${space}${space}Id name${space} 

    ${resp}=    Create Item Inventory  ${name2}    itemCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH4

    [Documentation]   Create Item Inv - category code is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Category code 

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH5

    [Documentation]   Create Item Inv - category Code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Category code 

    ${resp}=    Create Item Inventory  ${name2}    categoryCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH6

    [Documentation]   Create Item Inv - Subcategory is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Sub Category${space}${space}code

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH7

    [Documentation]   Create Item Inv - Sub category is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Sub Category${space}${space}code

    ${resp}=    Create Item Inventory  ${name2}    categoryCode2=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH8

    [Documentation]   Create Item Inv - type is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Type code

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH9

    [Documentation]   Create Item Inv - type is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Type code

    ${resp}=    Create Item Inventory  ${name2}    typeCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH10

    [Documentation]   Create Item Inv - sub type is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Sub Item Type name${space} 

    ${resp}=    Create Item Inventory  ${name2}    typeCode2=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH11

    [Documentation]   Create Item Inv - sub type is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Sub Item Type name${space}

    ${resp}=    Create Item Inventory  ${name2}    typeCode2=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH12

    [Documentation]   Create Item Inv - hsn is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   HSN name${space}

    ${resp}=    Create Item Inventory  ${name2}    hsnCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH13

    [Documentation]   Create Item Inv - hsn is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   HSN name${space}

    ${resp}=    Create Item Inventory  ${name2}    hsnCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH14

    [Documentation]   Create Item Inv - manufacturerCode is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Manufacturer code

    ${resp}=    Create Item Inventory  ${name2}    manufacturerCode=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}


JD-TC-CreateItemInv-UH15

    [Documentation]   Create Item Inv - manufacturerCode is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=            FakerLibrary.name
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Manufacturer code

    ${resp}=    Create Item Inventory  ${name2}    manufacturerCode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH16

    [Documentation]   Create Item Inv - itemGroups is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Group code

    ${inv}=  Create List  ${inv}

    ${resp}=    Create Item Inventory  ${name2}    itemGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH17

    [Documentation]   Create Item Inv - itemSubGroups is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999
    ${inv}=  Create List  ${inv}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Sub Item Group code

    ${resp}=    Create Item Inventory  ${name2}    itemSubGroups=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH18

    [Documentation]   Create Item Inv - tax is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${inv}=  Create List  ${inv}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Tax code

    ${resp}=    Create Item Inventory  ${name2}    tax=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH19

    [Documentation]   Create Item Inv - composition is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${inv}=  Create List  ${inv}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Composition code

    ${resp}=    Create Item Inventory  ${name2}    composition=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH20

    [Documentation]   Create Item Inv - itemUnits is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=       FakerLibrary.name
    ${inv}=         Random Int  min=999  max=9999

    ${inv}=  Create List  ${inv}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Item Units code

    ${resp}=    Create Item Inventory  ${name2}    itemUnits=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_FIELD}

JD-TC-CreateItemInv-UH21

    [Documentation]   Create Item Inv - without login

    ${name2}=            FakerLibrary.name

    ${resp}=    Create Item Inventory  ${name2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}

JD-TC-CreateItemInv-31

    [Documentation]   Create Item Inv with badge

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


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
    Set Test Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['badges'][0]['name']}                         ${name2}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['link']}                         ${name2}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['badges'][0]['attachments'][0]['driveId']}                 ${driveId}
