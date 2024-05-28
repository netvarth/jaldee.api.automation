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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/musers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_
${invalidItem}     sprx-3250dr0-800
@{spItemSource}      RX       Ayur
${originFrom}       NONE
@{deliveryType}     STORE_PICKUP        HOME_DELIVERY


*** Test Cases ***



JD-TC-Get Item Transaction Count Filter-1
    [Documentation]    1.Item Added to inventory catalog then check transaction----2.Purchase Item then check transaction----3.Add item to sales order catalog then check transcation----4.After sales order check transaction--

    ${resp}=  Encrypted Provider Login  ${MUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
# --------------------- Create Store Type from sa side -------------------------------
    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}
# --------------------- ---------------------------------------------------------------   
    ${resp}=  Encrypted Provider Login    ${MUSERNAME52}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}

   ${accountId}=  get_acc_id  ${MUSERNAME52}
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
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Suite Variable  ${address}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}

    sleep  02s
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END
    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
    END


# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Name_store}=    FakerLibrary.first name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${email_id}  ${Name_store}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name_store}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}


# ----------------------------------------  Create Item ---------------------------------------------

    ${itemName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${itemName1}    isInventoryItem=${bool[1]}    isBatchApplicable=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Batch_item1}  ${resp.json()}


# ----------------------------------------  Get Item ---------------------------------------------

    ${resp}=   Get Item Inventory  ${Batch_item1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${itemPropertyType}  ${resp.json()['itemPropertyType']}

# ------------------------------------------------------------------------------------------------------
# ----------------------------------------- create Inv Catalog -------------------------------------------------------

    ${resp}=  Create Inventory Catalog   ${Name_store}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${Batch_item1}   
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Batch_Item_id}   ${resp.json()[0]}

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------Get Item Transaction By Filter (After adding the item to inventory catalog).Should be []------------------------------------------------------------------------

    ${resp}=   Get Item Transaction By Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}       []
    ${len}=  Get Length  ${resp.json()}

    ${resp}=   Get Item Transaction Count Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}       ${len}


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

    # ............... Create Vendor ...............

    ${resp}=  Populate Url For Vendor   ${accountId}   
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
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${accountId}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

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
# -------------------------------------------------------------------------------------------------------------

# --------------------------------------- Do the Purchase--------------------------------------------------------------

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
    # ${convertionQty}=               Random Int  min=1  max=20

    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity} 
    ${totalQuantity}=   Evaluate    ${totalQuantity} * ${convertionQty}

    ${netTotal}=        Evaluate    ${quantity} * ${amount}
    ${discountAmount}=  Evaluate    ${netTotal} * ${discountPercentage} / 100
    ${taxableAmount}=   Evaluate    ${netTotal} - ${discountAmount}
    # ${cgstamount}=      Evaluate    ${taxableAmount} * ${cgst} / 100
    # ${sgstamount}=      Evaluate    ${taxableAmount} * ${sgst} / 100
    # ${taxAmount}=       Evaluate    ${cgstamount} + ${sgstamount}
    # ${netRate}=         Evaluate    ${taxableAmount} + ${taxAmount}

    ${expiryDate}=  db.add_timezone_date  ${tz}  50


    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=99

    ${purchaseItemDtoList2}=        Create purchaseItemDtoList   ${ic_Batch_Item_id}   ${quantity}  ${freeQuantity}  ${totalQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${taxableAmount}  0  ${netTotal}   ${expiryDate}  ${mrp}  ${batchNo}  0   0   ${iu_id}
    Set Suite Variable              ${purchaseItemDtoList2}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${Catalog_EncIds}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList2}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Suite Variable              ${purchaseId}           ${resp.json()}

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}
# -------------------------------------------  Update Purchase Status ------------------------------------------------
    ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Update Purchase Status  ${PurchaseStatus[2]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
# ---------------------------------------------------------------------------------------------------------------------
    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[2]}
    Set Suite Variable              ${totalConvertedQuantity}           ${resp.json()['totalConvertedQuantity']}

    ${resp}=  Get Inventoryitem      ${ic_Batch_Item_id}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable            ${batch}       ${resp.json()[0]['batch']}  
    Should Be Equal As Strings      ${resp.json()[0]['account']}          ${account_id}
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchInv']}          ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['availableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['onHoldQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['onArrivalQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['trueAvailableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['futureAvailableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}


# ------------------------------------------------------------------------------------------------------------
# ------------------------------------Get Item Transaction By Filter (After took sales order------------------------------------------------------------------------

    ${resp}=   Get Item Transaction By Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}          ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['catalogName']}          ${Name_store}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalogItem']['encId']}          ${ic_Batch_Item_id}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['itemSourceEnum']}          RX
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['spCode']}          ${Batch_item1}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['name']}          ${itemName1}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['itemPropertyType']}          ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()[0]['batch']}          ${batch}
    Should Be Equal As Strings      ${resp.json()[0]['updateType']}          ADD
    Should Be Equal As Strings      ${resp.json()[0]['updateTypeString']}          Add
    Should Be Equal As Strings      ${resp.json()[0]['updateQty']}          ${totalConvertedQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['transactionTypeEnum']}          ${transactionTypeEnum[3]}
    Should Be Equal As Strings      ${resp.json()[0]['referenceNo']}          ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['referenceDate']}          ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['referenceUid']}          ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}          ${user_id}
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}          ${DAY1}

    ${len}=  Get Length  ${resp.json()}

    ${resp}=   Get Item Transaction Count Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}       ${len}
# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Batch_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings      ${resp.json()[0]['uid']}          ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['account']}          ${account_id}
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchInv']}          ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['availableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['onHoldQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['onArrivalQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['trueAvailableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['futureAvailableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}


# --------------------------- Create SalesOrder Inventory Catalog-InvMgr True --------------------------
    ${Store_note}=  FakerLibrary.name
    ${inv_cat_encid_List}=  Create List  ${Catalog_EncIds}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Store_note}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}
# -----------------------------------------------------------------------------------

# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------
    ${price}=    Random Int  min=200   max=500

    # ${tax}=     Create List  ${itemtax_id}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_Batch_Item_id}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Batch_itemEncIds}  ${resp.json()[0]}

    ${resp}=  Get Inventoryitem      ${ic_Batch_Item_id}         
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
# ------------------------------Create Catalog Item Batch-invMgmt True-------------------------------
    ${resp}=   Create Catalog Item Batch-invMgmt True   ${SO_Batch_itemEncIds}    ${catalog_details}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid}  ${resp.json()[0]}

# ------------------------------------------------------------------------------------------------------

    ${resp}=   Get list by item encId   ${SO_Batch_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name1} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_Batch_itemEncIds}    
    # Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${Batch_item1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${itemName1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid} 



# ------------------------------------------------------------------------------------------------------------
# ------------------------------------Get Item Transaction By Filter (After adding sales order catalog item)------------------------------------------------------------------------

    ${resp}=   Get Item Transaction By Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=   Get Item Transaction Count Filter  storeEncId-eq=${store_id}   itemCode-eq=${Batch_item1}  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}       ${len}
# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${MUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${Cg_encid}=  Create Dictionary   encId=${inv_order_encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  


    ${quantity}=    Random Int  min=2   max=5
    ${quantity}=  Convert To Number  ${quantity}    1

    ${items}=  Create Dictionary   catItemEncId=${SO_Batch_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_Cata_Item_Batch_Encid}

    ${primaryMobileNo1}    Generate random string    10    123456789
    Set Suite Variable  ${primaryMobileNo1}

    # ${bill_Phone1}=   Create Dictionary   countryCode=${countryCodes[0]}           number=${primaryMobileNo1}

    # ${contactInfo1}=   Create Dictionary    phone=${bill_Phone1}         email=${email_id}      
    # Set Suite Variable  ${contactInfo1}

    # ${homeDeliveryAddress1}=   Create Dictionary    phone=${bill_Phone1}   firstName=${firstName}      lastName=${lastName}       email=${email_id}      address=${address}    city=${city}   postalCode=${postcode}     landMark=${address}
    # Set Suite Variable  ${homeDeliveryAddress1}

    # ${billingAddress1}=   Create Dictionary    phone=${bill_Phone1}   firstName=${firstName}      lastName=${lastName}       email=${email_id}      address=${address}    city=${city}   postalCode=${postcode}     landMark=${address}

    ${note}=  FakerLibrary.name
    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom}    ${items}    store=${store}        notes=${note}      notesForCustomer=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Batch_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
# -----------------------------------------------------------------------------------
# --------------------------------------------- Update SalesOrder Status to confirmed --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}


# ------------------------------------------- Check Stock ---------------------------------------------------
    ${Available_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    ${Available_Quantity}=  Convert To Number  ${Available_Quantity}    1

    ${resp}=    Get Stock Avaliability  ${ic_Batch_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['account']}          ${account_id}
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchInv']}          ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['availableQty']}          ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['onHoldQty']}          ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['onArrivalQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['trueAvailableQty']}          ${Available_Quantity}
    Should Be Equal As Strings      ${resp.json()[0]['futureAvailableQty']}          ${Available_Quantity}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}

# --------------------------------------------- Update SalesOrder Status from confirmed to completed --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[2]}
    Set Suite Variable  ${order_reference}  ${resp.json()['orderRef']}
    Set Suite Variable  ${order_uid}  ${resp.json()['uid']}


# ------------------------------------------- Check Stock ---------------------------------------------------


    ${resp}=    Get Stock Avaliability  ${ic_Batch_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['account']}          ${account_id}
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['isBatchInv']}          ${bool[0]}
    Should Be Equal As Strings      ${resp.json()[0]['availableQty']}          ${Available_Quantity}
    Should Be Equal As Strings      ${resp.json()[0]['onHoldQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['onArrivalQty']}          0.0
    Should Be Equal As Strings      ${resp.json()[0]['trueAvailableQty']}          ${Available_Quantity}
    Should Be Equal As Strings      ${resp.json()[0]['futureAvailableQty']}          ${Available_Quantity}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}

# ------------------------------------------------------------------------------------------------------------
# ------------------------------------Get Item Transaction By Filter (After took sales order)------------------------------------------------------------------------

    ${resp}=   Get Item Transaction By Filter       updateType-eq=${updateType[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()[0]['locationId']}          ${locId1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Name_store}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}          ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['catalogName']}          ${Name_store}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalogItem']['encId']}          ${ic_Batch_Item_id}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['itemSourceEnum']}          RX
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['spCode']}          ${Batch_item1}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['name']}          ${itemName1}
    Should Be Equal As Strings      ${resp.json()[0]['spItem']['itemPropertyType']}          ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()[0]['batch']}          ${batch}
    Should Be Equal As Strings      ${resp.json()[0]['updateType']}          SUBTRACT
    Should Be Equal As Strings      ${resp.json()[0]['updateTypeString']}          Subtract
    Should Be Equal As Strings      ${resp.json()[0]['updateQty']}          ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['transactionTypeEnum']}          ${transactionTypeEnum[7]}
    Should Be Equal As Strings      ${resp.json()[0]['referenceNo']}          ${order_reference}
    Should Be Equal As Strings      ${resp.json()[0]['referenceDate']}          ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['referenceUid']}          ${order_uid}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}          ${user_id}
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}          ${DAY1}
    ${len}=  Get Length  ${resp.json()}

    ${resp}=   Get Item Transaction Count Filter  updateType-eq=${updateType[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}       ${len}




