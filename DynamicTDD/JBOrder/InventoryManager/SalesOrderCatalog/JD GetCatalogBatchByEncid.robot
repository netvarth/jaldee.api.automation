*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${jpgfile}      /ebs/TDD/uploadimage.jpg
${fileSize}     0.00458
${order}        0


*** Test Cases ***
JD-TC-Get Catalog Batch by Encid-1
    [Documentation]  creating batch item when inventory manager is on

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}


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

    ${resp}=  Create Sample Location
    Set Suite Variable    ${loc_id}   ${resp}

    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ......... Create Store .........

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    # Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    # Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable            ${store_id}           ${resp.json()} 

    # ............... Create Vendor ...............

    ${resp}=  Populate Url For Vendor   ${account_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id1}
    Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}                
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${vendorId}     ${resp.json()['encId']}

    # .......... Create Inventory Catalog Item ..........

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    Set Suite Variable              ${unitName}
    Set Suite Variable              ${convertionQty}

    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}

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

    ${name}=                        FakerLibrary.name
    ${shortDesc}=                   FakerLibrary.sentence
    ${internalDesc}=                FakerLibrary.sentence
    Set Suite Variable              ${name}
    Set Suite Variable              ${shortDesc}
    Set Suite Variable              ${internalDesc}

    ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[1]}  isInventoryItem=${boolean[1]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}     
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable              ${itemEncId1}  ${resp.json()}

    ${resp}=  Get Item Inventory  ${itemEncId1}    
    Log   ${resp.json()}
    Set Suite Variable  ${sp-item-id}  ${resp.json()['id']}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200


    ${resp}=   Create Inventory Catalog Item  ${encid}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_id}   ${resp.json()[0]}

    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    ${amount}=                      Random Int  min=1  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    ${inventoryCatalogItem}=        Create Dictionary   encId=${ic_id}
    Set Suite Variable              ${quantity}
    Set Suite Variable              ${freeQuantity}
    Set Suite Variable              ${amount}
    Set Suite Variable              ${discountPercentage}
    Set Suite Variable              ${fixedDiscount}
    Set Suite Variable              ${inventoryCatalogItem}

    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity}
    ${netTotal}=        Evaluate    ${quantity} * ${amount}
    ${discountAmount}=  Evaluate    ${netTotal} * ${discountPercentage} / 100
    ${taxableAmount}=   Evaluate    ${netTotal} - ${discountAmount}
    ${cgstamount}=      Evaluate    ${taxableAmount} * ${cgst} / 100
    ${sgstamount}=      Evaluate    ${taxableAmount} * ${sgst} / 100
    ${taxAmount}=       Evaluate    ${cgstamount} + ${sgstamount}
    ${netRate}=         Evaluate    ${taxableAmount} + ${taxAmount}
    ${netRate}=  roundoff  ${netRate}  
    ${cgstamount}=  roundoff  ${cgstamount}  
    ${sgstamount}=  roundoff  ${sgstamount}  
    ${taxAmount}=  roundoff  ${taxAmount}  

    Set Suite Variable              ${totalQuantity}
    Set Suite Variable              ${netTotal}
    Set Suite Variable              ${discountAmount}
    Set Suite Variable              ${taxableAmount}
    Set Suite Variable              ${cgstamount}
    Set Suite Variable              ${sgstamount}
    Set Suite Variable              ${taxAmount}
    Set Suite Variable              ${netRate}

    # ${resp}=    Get Item Details Inventory  ${store_id}  ${vendorId}  ${inventoryCatalogItem}  ${quantity}  ${freeQuantity}   ${amount}  ${fixedDiscount}  ${discountPercentage}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}                     200


    # ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${name}  ${boolean[0]}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}   200
    # Set Suite Variable              ${inv_order_encid}    ${resp.json()}
    ${inv_cat_encid_List}=  Create List  ${encid}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1
    Set Suite Variable  ${price}
    # ${resp}=   Create Inventory Catalog Item  ${inv_cat_encid}   ${itemEncId1}  
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}



    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_id}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    # ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${inv_order_encid}     ${itemEncId1}     ${price}         
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${expiryDate}=  db.add_timezone_date  ${tz}  50

    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id}   ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}   ${iu_id}    

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${encid}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${purchaseId}           ${resp.json()}

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}

    ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[1]}


    # ${resp}=    Get Purchase By Uid  ${purchaseId} 
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}                 200
    # Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}

    # ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}     200

    # ${resp}=    Get Purchase By Uid  ${purchaseId} 
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}                 200
    # Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[1]}

    ${resp}=    Update Purchase Status  ${PurchaseStatus[2]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[2]}

    ${resp}=  Get Inventoryitem      ${ic_id}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_encid}  ${resp.json()[0]['uid']}
    ${enccid}=  Create Dictionary          encId=${batch_encid} 
    Set Suite Variable  ${enccid}

    ${Name1}=    FakerLibrary.last name
    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1
    ${catalog_details}=  Create Dictionary          name=${Name1}  price=${price1}   inventoryItemBatch=${enccid}   
    Set Suite Variable  ${catalog_details}  

    ${resp}=   Create Catalog Item Batch-invMgmt True   ${SO_itemEncIds}    ${catalog_details}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid}  ${resp.json()[0]}

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name1} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${inv_order_encid}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${name}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncIds}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[1]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 


JD-TC-Get Catalog Batch by Encid-2
    [Documentation]  creating multiple batch item for same catalog item batch when inventory manager is on

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.last name

    ${resp}=  Create Inventory Catalog   ${Name1}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${encid1}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${encid1}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_id1}   ${resp.json()[0]}



    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    ${amount}=                      Random Int  min=1  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    ${inventoryCatalogItem}=        Create Dictionary   encId=${ic_id1}


    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity}
    ${netTotal}=        Evaluate    ${quantity} * ${amount}
    ${discountAmount}=  Evaluate    ${netTotal} * ${discountPercentage} / 100
    ${taxableAmount}=   Evaluate    ${netTotal} - ${discountAmount}
    ${cgstamount}=      Evaluate    ${taxableAmount} * ${cgst} / 100
    ${sgstamount}=      Evaluate    ${taxableAmount} * ${sgst} / 100
    ${taxAmount}=       Evaluate    ${cgstamount} + ${sgstamount}
    ${netRate}=         Evaluate    ${taxableAmount} + ${taxAmount}
    ${netRate}=  roundoff  ${netRate}  
    ${cgstamount}=  roundoff  ${cgstamount}  
    ${sgstamount}=  roundoff  ${sgstamount}  
    ${taxAmount}=  roundoff  ${taxAmount}  



    # ${resp}=    Get Item Details Inventory  ${store_id}  ${vendorId}  ${inventoryCatalogItem}  ${quantity}  ${freeQuantity}   ${amount}  ${fixedDiscount}  ${discountPercentage}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}                     200
    # Should Be Equal As Strings      ${resp.json()['quantity']}              ${quantity}
    # Should Be Equal As Strings      ${resp.json()['freeQuantity']}          ${freeQuantity}
    # Should Be Equal As Strings      ${resp.json()['totalQuantity']}         ${totalQuantity}
    # Should Be Equal As Strings      ${resp.json()['amount']}                ${amount}
    # Should Be Equal As Strings      ${resp.json()['discountPercentage']}    ${discountPercentage}
    # Should Be Equal As Strings      ${resp.json()['discountAmount']}        ${discountAmount}
    # Should Be Equal As Strings      ${resp.json()['taxableAmount']}         ${taxableAmount}
    # Should Be Equal As Strings      ${resp.json()['cgstPercentage']}        ${cgst}
    # Should Be Equal As Strings      ${resp.json()['sgstPercentage']}        ${sgst}
    # Should Be Equal As Strings      ${resp.json()['cgst']}                  ${cgstamount}
    # Should Be Equal As Strings      ${resp.json()['sgst']}                  ${sgstamount}
    # Should Be Equal As Strings      ${resp.json()['taxPercentage']}         ${taxPercentage}
    # Should Be Equal As Strings      ${resp.json()['taxAmount']}             ${taxAmount}
    # Should Be Equal As Strings      ${resp.json()['netTotal']}              ${netTotal}
    # Should Be Equal As Strings      ${resp.json()['netRate']}               ${netRate}

    ${inv_cat_encid_List}=  Create List  ${encid1}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1



    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name1}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_order_encid1}  ${resp.json()}



    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid1}    ${boolean[1]}     ${ic_id1}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_itemEncIds1}  ${resp.json()[0]}


    ${expiryDate}=  db.add_timezone_date  ${tz}  50

    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id1}    ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}   ${iu_id}    

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${encid1}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Test Variable              ${purchaseId}           ${resp.json()}

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}

    ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[1]}


    ${resp}=    Update Purchase Status  ${PurchaseStatus[2]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[2]}


    ${resp}=  Get Inventoryitem      ${ic_id1}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${batch_encid1}  ${resp.json()[0]['uid']}
    ${enccid1}=  Create Dictionary          encId=${batch_encid1} 
    Set Test Variable  ${enccid1}

    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1
    ${catalog_details1}=  Create Dictionary          name=${Name1}  price=${price1}   inventoryItemBatch=${enccid1}   
    Set Test Variable  ${catalog_details1}  

    ${resp}=   Create Catalog Item Batch-invMgmt True   ${SO_itemEncIds1}     ${catalog_details1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid1}  ${resp.json()[0]}

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name1} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncIds1}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${inv_order_encid1}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name1}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${name}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncIds1}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[1]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid1} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 



JD-TC-Get Catalog Batch by Encid-3
    [Documentation]    update batch and get catalog batch by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventoryitem      ${ic_id1}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_encid1}  ${resp.json()[0]['uid']}
    ${encids}=  Create Dictionary          encId=${batch_encid1} 

    ${Name2}=    FakerLibrary.last name
    ${price2}=    Random Int  min=2   max=40
    ${price2}=  Convert To Number  ${price2}    1

    ${resp}=   Update Catalog Item Batch-invMgmt True   ${SO_Cata_Item_Batch_Encid}  ${Name2}     ${price2}     inventoryItemBatch=${encids}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price2}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name2} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${inv_order_encid}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${name}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncIds}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[1]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 


JD-TC-Get Catalog Batch by Encid-4
    [Documentation]    update batch status as disable and get catalog batch by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Catalog Item Batch Status   ${SO_Cata_Item_Batch_Encid1}     ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[1]} 


JD-TC-Get Catalog Batch by Encid-UH1
    [Documentation]   Get Catalog Item Batch By Encid with invalid catalog batch id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch By Encid   ${itemEncId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVENORY_CATALOG_ITEM_BATCH}
    

JD-TC-Get Catalog Batch by Encid-UH2
    [Documentation]   Get Catalog Item Batch By Encid without login

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Catalog Batch by Encid-UH3
    [Documentation]  Get Catalog Item Batch By Encid using sa login.(inventory manager is false)

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


*** Comments ***
JD-TC-Get Catalog Batch by Encid-1
    [Documentation]   create of a batch of catalog items then get catalog batch by encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME32}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    # ${resp}=  Create SalesOrder Inventory Catalog   ${store_id}   ${Name}  ${boolean[1]}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_cat_id}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${Inv_cat_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}

    ${resp}=    Create Item Inventory  ${displayName}   isBatchApplicable=${boolean[1]}   isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=  Get Item Inventory  ${itemEncId1}    
    Log   ${resp.json()}
    Set Suite Variable  ${sp-item-id}  ${resp.json()['id']}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_item_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_item_Id}   isInventoryItem=${bool[1]}   isBatchApplicable=${boolean[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1
    Set Suite Variable  ${price}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${spItem}=  Create Dictionary  encId=${itemEncId1}   
    ${resp}=    Update SalesOrder Catalog Item      ${SO_itemEncIds}     ${boolean[1]}         ${price}    spItem=${spItem}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${catalogItem}=     Create Dictionary       encId=${SO_itemEncIds}
    #  catalogItem=${catalogItem}    

    ${resp}=   Create Catalog Item Batch-invMgmt False   ${SO_itemEncIds}     ${Name}     ${price}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid}  ${resp.json()[0]}

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${SO_Cata_Encid}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${displayName}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncIds}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[0]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${Name} 



JD-TC-Get Catalog Batch by Encid-2
    [Documentation]   create salesorder catalog items where inventory management is true then create catalog item batch where invmgnt is false then get batch by encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid1}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${SO_Cata_Encid1}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncId1}  ${resp.json()[0]}

    ${resp}=  Create Catalog Item Batch-invMgmt False      ${SO_itemEncId1}     ${Name}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid1}  ${resp.json()[0]}

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncId1}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${SO_Cata_Encid1}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${displayName}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncId1}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[0]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid1} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${Name} 


JD-TC-Get Catalog Batch by Encid-3
    [Documentation]    create new catalog item batch and get catalog batch by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.last name
    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1
    ${Name2}=    FakerLibrary.last name
    ${price2}=    Random Int  min=2   max=40
    ${price2}=  Convert To Number  ${price2}    1
    ${catalog_details}=  Create Dictionary          name=${Name1}   price=${price1}   

    ${resp}=   Create Catalog Item Batch-invMgmt False   ${SO_itemEncIds}     ${Name2}     ${price2}     ${catalog_details}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid2}  ${resp.json()[0]}
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid3}  ${resp.json()[1]}

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid3}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()['price']}    1
    ${sorderCatalogItem_price}=  Convert To Number  ${resp.json()['sorderCatalogItem']['price']}     1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()['name']}    ${Name1} 
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['accountId']}    ${accountId}    
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['encId']}    ${SO_Cata_Encid}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['name']}    ${Name}   
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['catalog']['invMgmt']}    ${bool[0]}  
    Should Be Equal As Strings    ${sorderCatalogItem_price}    ${price}      
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['spItem']['name']}    ${displayName}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['encId']}    ${SO_itemEncIds}  
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['sorderCatalogItem']['invMgmt']}     ${bool[0]} 
    Should Be Equal As Strings    ${resp.json()['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_Cata_Item_Batch_Encid3} 
    Should Be Equal As Strings    ${resp.json()['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()['name']}     ${Name1} 


