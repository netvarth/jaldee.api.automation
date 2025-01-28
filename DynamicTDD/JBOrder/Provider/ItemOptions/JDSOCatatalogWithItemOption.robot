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


*** Test Cases ***

JD-TC-CreateItemWithOptions-1

    [Documentation]   Create Catalog- Item With Item Options- INV OFF

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ......... Create Store .........

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SName}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${SName}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Test Variable      ${SName}

    ${resp}=  Create Store   ${SName}   ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}   ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable            ${store_id}           ${resp.json()}

    # Create item 1- INV OFF
    ${values1}   Create List  Black   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
     ${values2}   Create List   S    L
    ${option2}=  Create Dictionary  attribute=size  position=${2}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}    ${option2} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem1}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem2}   ${resp.json()[1]['spCode']}
    Set Suite Variable     ${singleItem3}   ${resp.json()[2]['spCode']}   
    Set Suite Variable     ${singleItem4}   ${resp.json()[3]['spCode']}

    # Create SalesOrder catalog- Inventory OFF
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}    ${Name}   ${boolean[0]}   onlineSelfOrder=${boolean[1]}   walkInOrder=${boolean[1]}    storePickup=${boolean[1]}   homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id1}    ${resp.json()}

   ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Suite Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${item}      ${price}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${soc_id1} 
    Log   ${resp.content}

    ${resp}=  Get SalesOrder Catalog Item Count    sorderCatalogEncId-eq=${soc_id1} 
    Log   ${resp.content}

JD-TC-CreateItemWithOptions-2

    [Documentation]   Create Catalog- Item With Item Options- INV ON, BATCH OFF

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Create item 1- INV ON, BATCH OFF
    ${values1}   Create List  Black   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
     ${values2}   Create List   S    L
    ${option2}=  Create Dictionary  attribute=size  position=${2}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}    ${option2} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem1}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem2}   ${resp.json()[1]['spCode']}
    Set Suite Variable     ${singleItem3}   ${resp.json()[2]['spCode']}   
    Set Suite Variable     ${singleItem4}   ${resp.json()[3]['spCode']}

    #Create inventory catalog and add virtual items(with all of its single items)
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

    ${resp}=   Create Inventory Catalog Item   ${inv_cat_encid1}   ${item} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}

    ${resp}=  Get Inventory Catalog By EncId   ${inv_cat_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 

    # Create SalesOrder catalog- Inventory ON
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}   ${Name}  ${boolean[1]}  ${inv_cat_encid}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${soc_id1}    ${boolean[1]}     ${Inv_Cata_Item_Encid1}     ${price}    ${boolean[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}

     ${resp}=  Get SalesOrder Catalog Item List   sorderCatalogEncId-eq=${soc_id1} 
    Log   ${resp.content}

    ${resp}=  Get SalesOrder Catalog Item Count   sorderCatalogEncId-eq=${soc_id1} 
    Log   ${resp.content}


JD-TC-CreateItemWithOptions-3

    [Documentation]   Create Catalog- Item With Item Options- INV ON, BATCH ON

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ..... Create Unit ......

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}

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
    Should Be Equal As Strings  ${resp.status_code}  200

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

    # Create item 1- INV ON, BATCH OFF

    ${values1}   Create List  Black   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
     ${values2}   Create List   S    L
    ${option2}=  Create Dictionary  attribute=size  position=${2}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}    ${option2} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[1]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}     itemUnits=${itemUnits}   tax=${tax} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem1}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem2}   ${resp.json()[1]['spCode']}
    Set Suite Variable     ${singleItem3}   ${resp.json()[2]['spCode']}   
    Set Suite Variable     ${singleItem4}   ${resp.json()[3]['spCode']}

    #Create inventory catalog and add virtual items(with all of its single items)
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

    ${resp}=   Create Inventory Catalog Item   ${inv_cat_encid1}   ${item} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cata_item_encid1}  ${resp.json()[0]}

    ${resp}=  Get Inventory Catalog By EncId   ${inv_cat_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cata_sing_item1}  ${resp.json()['icItemList'][1]['encId']}
    Set Test Variable  ${inv_cata_sing_item2}  ${resp.json()['icItemList'][2]['encId']}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 

    # Create SalesOrder catalog- Inventory ON
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}   ${Name}  ${boolean[1]}  ${inv_cat_encid}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${soc_id1}    ${boolean[1]}     ${inv_cata_item_encid1}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}
 
    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    ${convertionQty}=               Random Int  min=1  max=20
    Set Suite Variable              ${convertionQty}
    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${expiryDate}=  db.add_timezone_date  ${tz}  50
    ${amount}=                      Random Int  min=1  max=500
    ${amount}=                      Convert To Number  ${amount}  1
    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=500  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10
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
     ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    ${inventoryCatalogItem}=        Create Dictionary   encId=${SO_itemEncIds}
    Set Suite Variable              ${totalQuantity}
    Set Suite Variable              ${netTotal}
    Set Suite Variable              ${discountAmount}
    Set Suite Variable              ${taxableAmount}
    Set Suite Variable              ${cgstamount}
    Set Suite Variable              ${sgstamount}
    Set Suite Variable              ${taxAmount}
    Set Suite Variable              ${netRate}

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${inv_cata_sing_item1}   ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}   ${iu_id}    

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${inv_cat_encid1}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
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

    ${resp}=    Update Purchase Status  ${PurchaseStatus[2]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[2]}

    ${resp}=  Get Inventoryitem      ${inv_cata_sing_item1}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_encid1}  ${resp.json()[0]['uid']}
    ${enccid}=  Create Dictionary          encId=${batch_encid1} 
    Set Suite Variable  ${enccid}

     ${resp}=  Get Inventoryitem      ${inv_cata_sing_item2}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_encid2}  ${resp.json()[0]['uid']}
    ${enccid2}=  Create Dictionary          encId=${batch_encid2} 
    Set Suite Variable  ${enccid2}

    ${Name1}=    FakerLibrary.last name
    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1
    ${catalog_details}=  Create Dictionary          name=${Name1}  price=${price1}   inventoryItemBatch=${enccid}   
    Set Suite Variable  ${catalog_details}  

    ${resp}=   Create Catalog Item Batch-invMgmt True   ${SO_itemEncIds}    ${catalog_details}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventory Item Count   storeEncId-eq=${store_id}   invCatalogEncId-eq=${inv_cat_encid1}   from=0  count=10
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200