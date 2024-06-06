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
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_
${invalidItem}     sprx-3250dr0-800
@{spItemSource}      RX       Ayur
${originFrom}       NONE
@{deliveryType}     STORE_PICKUP        HOME_DELIVERY

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
      
*** Test Cases ***

JD-TC-Inventory Manager Work Flow-1
    [Documentation]    create a sales order with inventory ON case.
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+45485121
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}

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

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${accountId}=  get_acc_id  ${HLPUSERNAME16}
    # Set Suite Variable    ${accountId} 

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

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Store_Name1}=    FakerLibrary.first name
    Set Suite Variable  ${Store_Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${email_id}  ${Store_Name1}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Item_id}   ${resp.json()[0]}

# -------------------------------------------------------------------------------------------------------------

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
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id}
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
# -----------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- Create itemUnits ------------------------------------------------------------------

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    Set Suite Variable              ${unitName}
    Set Suite Variable              ${convertionQty}

    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}


# --------------------------------------- Do the Purchase--------------------------------------------------------------

    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    Set Suite Variable  ${quantity}

    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    Set Suite Variable  ${freeQuantity}

    ${amount}=                      Random Int  min=1  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    Set Suite Variable  ${amount}

    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    Set Suite Variable  ${discountPercentage}

    ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    Set Suite Variable  ${fixedDiscount}

    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity} 
    ${totalQuantity}=   Evaluate    ${totalQuantity} * ${convertionQty}
    Set Suite Variable  ${totalQuantity}

    ${netTotal}=        Evaluate    ${quantity} * ${amount}
    ${discountAmount}=  Evaluate    ${netTotal} * ${discountPercentage} / 100
    ${taxableAmount}=   Evaluate    ${netTotal} - ${discountAmount}
    # ${cgstamount}=      Evaluate    ${taxableAmount} * ${cgst} / 100
    # ${sgstamount}=      Evaluate    ${taxableAmount} * ${sgst} / 100
    # ${taxAmount}=       Evaluate    ${cgstamount} + ${sgstamount}
    # ${netRate}=         Evaluate    ${taxableAmount} + ${taxAmount}

    ${expiryDate}=  db.add_timezone_date  ${tz}  50
    ${convertionQty}=               Random Int  min=1  max=20

    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList   ${ic_Item_id}   ${quantity}  ${freeQuantity}  ${totalQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${taxableAmount}  0  ${netTotal}   ${expiryDate}  ${mrp}  ${EMPTY}  0   0   ${iu_id}
    Set Suite Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${Catalog_EncIds}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
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

    ${resp}=  Get Inventoryitem      ${ic_Item_id}         
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}


# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# -----------------------------------------------------------------------------------

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

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr True --------------------------

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${Store_name}=  FakerLibrary.name
    Set Suite Variable    ${Store_name}
    ${inv_cat_encid_List}=  Create List  ${Catalog_EncIds}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Store_name}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}
# ---------------------------------------------------------------------------------------------------------
# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_Item_id}     ${price}    ${boolean[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

# ----------------------------------------------------------------------------------------------------------

# ----------------------------------------- Take sales order ------------------------------------------------
    ${Cg_encid}=  Create Dictionary   encId=${inv_order_encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  


    ${quantity}=    Random Int  min=2   max=5
    ${quantity}=  Convert To Number  ${quantity}    1

    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

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
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
# -----------------------------------------------------------------------------------
# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

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

    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}
# -----------------------------------------------------------------------------------

# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[2]}
# ------------------------------------------- Check Stock ---------------------------------------------------
    ${Available_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    ${Available_Quantity}=  Convert To Number  ${Available_Quantity}    1

    # ${total_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    # ${total_Quantity}=  Convert To Number  ${total_Quantity}    1

    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# ------------------------------------------------Create Sales Order Invoice----------------------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Get Invoice By Invoice EncId -----------------------------------------------

    ${netTotal}=   Evaluate    ${price} * ${quantity} 
    ${netTotal}=  Convert To Number  ${netTotal}    1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[0]}

# ------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Generate SO Payment Link -----------------------------------------------

    ${resp}=    Generate SO Payment Link    ${SO_Inv}   ${primaryMobileNo}   ${countryCodes[0]}   ${email_id}    ${bool[1]}    ${bool[0]}    ${bool[0]}   ${primaryMobileNo}   ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------- Share SO Invoice -----------------------------------------------

    ${PO_Number}    Generate random string    5    123456789
    ${PO_Number}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${phone}=   Create Dictionary       number=${PO_Number}      countryCode=${countryCodes[0]}  

    ${resp}=    Share SO Invoice    ${SO_Inv}    ${email_id}   ${bool[1]}    ${bool[0]}  ${bool[0]}   ${bool[0]}    ${html}   phone=${phone}    whatsappPhNo=${phone}      telegramPhNo=${phone}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Consumer do the payment via link -----------------------------------------------

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    SO Payment Via Link    ${SO_Inv}    ${netTotal}   ${purpose[7]}    ${accountId}    ${finance_payment_modes[8]}     ${bool[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['netRate']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['amountDue']}                                      0.0
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[1]}

JD-TC-Inventory Manager Work Flow-2
    [Documentation]    create a sales order with inventory ON case and tax is true.
    
    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME44}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

    ${resp}=    Create Item Inventory  ${name}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[0]}    itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}     isInventoryItem=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${TAX_item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${TAX_item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemCode']}                  ${itemjrx}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemName']}                  ${itemName}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['description']}               ${description}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['sku']}                       ${sku}
    Should Be Equal As Strings      ${resp.json()['name']}                                      ${name}
    Should Be Equal As Strings      ${resp.json()['shortDesc']}                                 ${shortDesc}
    Should Be Equal As Strings      ${resp.json()['internalDesc']}                              ${internalDesc}
    Should Be Equal As Strings      ${resp.json()['isInventoryItem']}                           ${bool[1]}
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
    # Should Be Equal As Strings      ${resp.json()['composition'][0]}                            ${compositionCode}
    Should Be Equal As Strings      ${resp.json()['sku']}                                       ${sku}
    # Should Be Equal As Strings      ${resp.json()['itemUnits'][0]}                              ${iu_id}
    Should Be Equal As Strings      ${resp.json()['isBatchApplicable']}                         ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${toggle[0]}
    Set Suite Variable              ${spCode}     ${resp.json()['spCode']}                               

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Inv Catalog -------------------------------------------------------
    # ${INV_Cat_Name}=     FakerLibrary.name

    # ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${Catalog_EncIds1}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${TAX_item}   
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_TAX_Item_id}   ${resp.json()[0]}

# -------------------------------------------------------------------------------------------------------------
    ${inventoryCatalogItem}=        Create Dictionary   encId=${ic_TAX_Item_id}

    # ${resp}=    Get Item Details Inventory  ${store_id}  ${vendorId}  ${inventoryCatalogItem}  ${quantity}  ${freeQuantity}   ${amount}  ${fixedDiscount}  ${discountPercentage}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}                     200
    # # Should Be Equal As Strings      ${resp.json()['quantity']}              ${quantity}
    # # Should Be Equal As Strings      ${resp.json()['freeQuantity']}          ${freeQuantity}
    # # Should Be Equal As Strings      ${resp.json()['totalQuantity']}         ${totalQuantity}
    # # Should Be Equal As Strings      ${resp.json()['amount']}                ${amount}
    # # Should Be Equal As Strings      ${resp.json()['discountPercentage']}    ${discountPercentage}
    # # Should Be Equal As Strings      ${resp.json()['discountAmount']}        ${discountAmount}
    # # Should Be Equal As Strings      ${resp.json()['taxableAmount']}         ${taxableAmount}
    # # Should Be Equal As Strings      ${resp.json()['cgstPercentage']}        ${cgst}
    # # Should Be Equal As Strings      ${resp.json()['sgstPercentage']}        ${sgst}
    # # Should Be Equal As Strings      ${resp.json()['cgst']}                  ${cgstamount}
    # # Should Be Equal As Strings      ${resp.json()['sgst']}                  ${sgstamount}
    # # Should Be Equal As Strings      ${resp.json()['taxPercentage']}         ${taxPercentage}
    # # Should Be Equal As Strings      ${resp.json()['taxAmount']}             ${taxAmount}
    # # Should Be Equal As Strings      ${resp.json()['netTotal']}              ${netTotal}
    # # Should Be Equal As Strings      ${resp.json()['netRate']}               ${netRate}

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
    ${convertionQty}=               Random Int  min=1  max=20

    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10

    ${purchaseItemDtoList2}=        Create purchaseItemDtoList   ${ic_TAX_Item_id}   ${quantity}  ${freeQuantity}  ${totalQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${taxableAmount}  0  ${netTotal}   ${expiryDate}  ${mrp}  ${EMPTY}  0   0   ${iu_id}
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

    ${resp}=  Get Inventoryitem      ${ic_TAX_Item_id}         
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}
    # Should Be Equal As Strings      ${resp.json()[0]}          ${PURCHASE_ALREADY_IN_STATUS}


# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_TAX_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# -----------------------------------------------------------------------------------

# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------
    ${price}=    Random Int  min=200   max=500

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Set Suite Variable              ${itemtax_id}           ${resp.json()['id']}

    ${tax}=     Create List  ${itemtax_id}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_TAX_Item_id}     ${price}    ${boolean[0]}   taxInclude=${boolean[1]}    taxes=${tax}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${resp}=  Get SalesOrder Catalog Item By Encid      ${SO_itemEncIds}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventoryitem      ${ic_TAX_Item_id}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ----------------------------------------------------------------------------------------------------------

# ----------------------------------------- Take sales order ------------------------------------------------
    ${Cg_encid}=  Create Dictionary   encId=${inv_order_encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  


    ${quantity}=    Random Int  min=2   max=5
    ${quantity}=  Convert To Number  ${quantity}    1

    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

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
    ${resp}=    Get Stock Avaliability  ${ic_TAX_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
# -----------------------------------------------------------------------------------
# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

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

    ${resp}=    Get Stock Avaliability  ${ic_TAX_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}
# -----------------------------------------------------------------------------------

# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[2]}
# ------------------------------------------- Check Stock ---------------------------------------------------
    ${Available_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    ${Available_Quantity}=  Convert To Number  ${Available_Quantity}    1

    # ${total_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    # ${total_Quantity}=  Convert To Number  ${total_Quantity}    1

    ${resp}=    Get Stock Avaliability  ${ic_TAX_Item_id}
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# ------------------------------------------------Create Sales Order Invoice----------------------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Get Invoice By Invoice EncId -----------------------------------------------

    ${netTotal}=   Evaluate    ${price} * ${quantity} 
    ${netTotal}=  Convert To Number  ${netTotal}    1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[0]}

# ------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Generate SO Payment Link -----------------------------------------------

    ${resp}=    Generate SO Payment Link    ${SO_Inv}   ${primaryMobileNo}   ${countryCodes[0]}   ${email_id}    ${bool[1]}    ${bool[0]}    ${bool[0]}   ${primaryMobileNo}   ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------- Share SO Invoice -----------------------------------------------

    ${PO_Number}    Generate random string    5    123456789
    ${PO_Number}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${phone}=   Create Dictionary       number=${PO_Number}      countryCode=${countryCodes[0]}  

    ${resp}=    Share SO Invoice    ${SO_Inv}    ${email_id}   ${bool[1]}    ${bool[0]}  ${bool[0]}   ${bool[0]}    ${html}   phone=${phone}    whatsappPhNo=${phone}      telegramPhNo=${phone}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Consumer do the payment via link -----------------------------------------------

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    SO Payment Via Link    ${SO_Inv}    ${netTotal}   ${purpose[7]}    ${accountId}    ${finance_payment_modes[8]}     ${bool[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['netRate']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['amountDue']}                                      0.0
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[1]}

JD-TC-Inventory Manager Work Flow-3
    [Documentation]    take a sales order  inventory is ON and item inv and batch is true.
    
    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

# ----------------------------------------  Create Item ---------------------------------------------

    ${itemName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${itemName1}    isInventoryItem=${bool[1]}    isBatchApplicable=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Batch_item1}  ${resp.json()}

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${Batch_item1}   
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Batch_Item_id}   ${resp.json()[0]}

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
    ${convertionQty}=               Random Int  min=1  max=20

    ${salesRate}=   Evaluate        ${amount} / ${convertionQty}
    ${invoiceDate}=  db.add_timezone_date  ${tz}  1
    ${rate}=        Evaluate        int(${salesRate})
    ${mrp}=         Random Int      min=${rate}  max=9999
    ${batchNo}=     Random Int      min=1  max=9999
    ${invoiceReferenceNo}=          Random Int  min=1  max=999
    ${purchaseNote}=                FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=1  max=10

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

    ${resp}=  Get Inventoryitem      ${ic_Batch_Item_id}         
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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# -----------------------------------------------------------------------------------

# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------
    ${price}=    Random Int  min=200   max=500

    ${tax}=     Create List  ${itemtax_id}

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
# -------------------------------------------------------------------------------------------------------------
# ----------------------------------------- Take sales order ------------------------------------------------
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
# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}
# -----------------------------------------------------------------------------------

# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[2]}
# ------------------------------------------- Check Stock ---------------------------------------------------
    ${Available_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    ${Available_Quantity}=  Convert To Number  ${Available_Quantity}    1

    # ${total_Quantity}=   Evaluate    ${totalQuantity} - ${quantity} 
    # ${total_Quantity}=  Convert To Number  ${total_Quantity}    1

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
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}          ${Store_Name1}

# ------------------------------------------------Create Sales Order Invoice----------------------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Get Invoice By Invoice EncId -----------------------------------------------

    ${netTotal}=   Evaluate    ${price1} * ${quantity} 
    ${netTotal}=  Convert To Number  ${netTotal}    1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[0]}

# --------------------------------------------- Generate SO Payment Link -----------------------------------------------

    ${resp}=    Generate SO Payment Link    ${SO_Inv}   ${primaryMobileNo}   ${countryCodes[0]}   ${email_id}    ${bool[1]}    ${bool[0]}    ${bool[0]}   ${primaryMobileNo}   ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------- Share SO Invoice -----------------------------------------------

    ${PO_Number}    Generate random string    5    123456789
    ${PO_Number}=  Evaluate  ${PUSERNAME}+${PO_Number}

    ${phone}=   Create Dictionary       number=${PO_Number}      countryCode=${countryCodes[0]}  

    ${resp}=    Share SO Invoice    ${SO_Inv}    ${email_id}   ${bool[1]}    ${bool[0]}  ${bool[0]}   ${bool[0]}    ${html}   phone=${phone}    whatsappPhNo=${phone}      telegramPhNo=${phone}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------------
# --------------------------------------------- Consumer do the payment via link -----------------------------------------------

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    SO Payment Via Link    ${SO_Inv}    ${netTotal}   ${purpose[7]}    ${accountId}    ${finance_payment_modes[8]}     ${bool[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    # Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    # Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    # Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Store_name}
    # Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${inv_order_encid}
    # Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    # Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    # Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    # # Should Be Equal As Strings    ${resp.json()['netRate']}                                       0.0
    # # Should Be Equal As Strings    ${resp.json()['amountDue']}                                      0.0
    # Should Be Equal As Strings    ${resp.json()['amountPaid']}                                      ${netTotal}
    # Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
    # Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[1]}

# --------------------------------------------- Update Sales Order Invoice Status -----------------------------------------------

    ${resp}=    Update Sales Order Invoice Status    ${SO_Inv}    ${billStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200   
    Should Be Equal As Strings    ${resp.json()['status']}                                      ${billStatus[1]}
# --------------------------------------------------------------------------------------------------------------------------------------
    ${note}=  FakerLibrary.name

    ${resp}=    Make Cash Payment For SalesOrder    ${SO_Inv}   ${acceptPaymentBy[0]}	${netTotal}     ${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      0.0
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       ${netTotal}