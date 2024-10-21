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
Library         /ebs/TDD/CustomKeywords.py
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
${order}        0
      

*** Test Cases ***

JD-TC-Get Stock Transfer Count Filter-1
    [Documentation]    Get Stock Transfer Count Filter.
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  generate_firstname
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+57799665
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
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


    ${lid}=  Create Sample Location

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Suite Variable  ${address}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}


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


# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${accountId}=  get_acc_id  ${HLPUSERNAME16}
    # Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type ByEncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



# ------------------------ Create Source Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Store_Name1}=    FakerLibrary.first name
    Set Suite Variable  ${Store_Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+108107784
    Set Suite Variable  ${email_id}  ${Store_Name1}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${lid}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${Stidd1}    ${resp.json()['id']}

# ---------------------------------------------------------------------------------------------------

# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Source Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name
    Set Suite Variable  ${INV_Cat_Name}

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Source Inventory Catalog Item----------------------------------

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


    ${vender_name}=   generate_firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456798
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

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList   ${ic_Item_id}   ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${EMPTY}  ${iu_id}
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

 


# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


# -----------------------------------------------------------------------------------
# ------------------------ Create Destination Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Store_Name2}=    FakerLibrary.first name
    Set Suite Variable  ${Store_Name2}
    ${PhoneNumber2}=  Evaluate  ${PUSERNAME}+200184877
    Set Suite Variable  ${email_id}  ${Store_Name2}${PhoneNumber2}.${test_mail}
    ${email1}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name2}  ${St_Id}    ${lid}  ${email1}     ${PhoneNumber2}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id2}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${Stidd}    ${resp.json()['id']}


# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Destination Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name2}=     FakerLibrary.name
    Set Suite Variable  ${INV_Cat_Name2}

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name2}  ${store_id2}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds2}  ${resp.json()}



# -------------------------------------------Create Store Transfer-----------------------------------------------------------------
    ${sourceInvCatalogItem}=  Create Dictionary  encId=${ic_Item_id}  
    ${transferQuantity}=   Evaluate    ${totalQuantity} - 30
    Set Suite Variable  ${transferQuantity}
    ${list}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=${transferQuantity}
    ${items}=  Create List  ${list}
    ${resp}=  Create Stock Transfer   ${DAY1}  ${store_id}    ${store_id2}  ${Catalog_EncIds}     ${Catalog_EncIds2}  items=${items}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Stock_transfer_uid}  ${resp.json()['uid']}

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Suite Variable              ${destinationInvCatalogItem_uid}         ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}


    ${resp}=  Get Stock Transfer Count Filter   uid-eq=${Stock_transfer_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                1

JD-TC-Get Stock Transfer Count Filter-2
    [Documentation]    status changed to received and stock transfer from destination to source then filter using stock transfer count filter.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Update Stock Transfer Status   ${Stock_transfer_uid}  ${stockTransfer[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Stock Transfer Status   ${Stock_transfer_uid}  ${stockTransfer[2]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sourceInvCatalogItem}=  Create Dictionary  encId=${destinationInvCatalogItem_uid}  
    Set Suite Variable  ${sourceInvCatalogItem}
    ${transferQuantity2}=   Evaluate    ${transferQuantity} - 20
    Set Suite Variable  ${transferQuantity2}
    ${list}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=${transferQuantity2}
    ${items}=  Create List  ${list}
    ${resp}=  Create Stock Transfer   ${DAY1}  ${store_id2}    ${store_id}  ${Catalog_EncIds2}     ${Catalog_EncIds}  items=${items}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Stock_transfer_uid1}  ${resp.json()['uid']}

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${refNo}                                   ${resp.json()['refNo']}
    Set Suite Variable              ${Stock_transferItem_uid}                                   ${resp.json()['items'][0]['uid']}
    Set Suite Variable              ${sourceInvCatalogId}                                   ${resp.json()['sourceInvCatalog']['id']}  
    Set Suite Variable              ${destinationInvCatalogId}                               ${resp.json()['destinationInvCatalog']['id']}  

    ${resp}=  Get Stock TransferFilter   sourceLocationId-eq=${lid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}



    ${resp}=  Get Stock Transfer Count Filter   sourceLocationId-eq=${lid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}


JD-TC-Get Stock Transfer Count Filter-3
    [Documentation]    Get Stock Transfer Count Filter using refno.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter   refNo-eq=${refNo} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}


    ${resp}=  Get Stock Transfer Count Filter   refNo-eq=${refNo} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-4
    [Documentation]    update stock transfer then Get Stock Transfer Count Filter using sourceStoreId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${list1}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=2  uid=${Stock_transfer_uid1}
    ${items1}=  Create List  ${list1}

    ${resp}=  Update Stock Transfer   ${Stock_transfer_uid1}   ${DAY1}  ${store_id2}    ${store_id}  ${Catalog_EncIds2}     ${Catalog_EncIds}  items=${items1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter    sourceStoreId-eq=${Stidd} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceStoreId-eq=${Stidd} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}


JD-TC-Get Stock Transfer Count Filter-5
    [Documentation]     Get Stock Transfer Count Filter using sourceLocationName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceLocationName-eq=${place} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceLocationName-eq=${place} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
     Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-6
    [Documentation]     Get Stock Transfer Count Filter using destinationLocationId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=  Get Stock TransferFilter     destinationLocationId-eq=${lid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationLocationId-eq=${lid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-7
    [Documentation]     Get Stock Transfer Count Filter using destinationLocationName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationLocationName-eq=${place}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationLocationName-eq=${place} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-8
    [Documentation]     Get Stock Transfer Count Filter using transferDate.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     transferDate-eq=${DAY1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   transferDate-eq=${DAY1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-9
    [Documentation]    Get Stock Transfer Count Filter using sourceStoreEncId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceStoreEncId-eq=${store_id2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceStoreEncId-eq=${store_id2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-10
    [Documentation]    Get Stock Transfer Count Filter using sourceStoreName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceStoreName-eq=${Store_Name2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceStoreName-eq=${Store_Name2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-11
    [Documentation]    Get Stock Transfer Count Filter using destinationStoreId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationStoreId-eq=${Stidd1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationStoreId-eq=${Stidd1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-12
    [Documentation]    Get Stock Transfer Count Filter using destinationStoreId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationStoreEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationStoreEncId-eq=${store_id} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-13
    [Documentation]    Get Stock Transfer Count Filter using destinationStoreId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationStoreName-eq=${Store_Name1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationStoreName-eq=${Store_Name1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-14
    [Documentation]    Get Stock Transfer Count Filter using sourceInvCatalogId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceInvCatalogId-eq=${sourceInvCatalogId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceInvCatalogId-eq=${sourceInvCatalogId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-15
    [Documentation]    Get Stock Transfer Count Filter using sourceInvCatalogEncId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceInvCatalogEncId-eq=${Catalog_EncIds2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   sourceInvCatalogEncId-eq=${Catalog_EncIds2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-16
    [Documentation]    Get Stock Transfer Count Filter using sourceInvCatalogName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     sourceInvCatalogName-eq=${INV_Cat_Name2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}


    ${resp}=  Get Stock Transfer Count Filter   sourceInvCatalogName-eq=${INV_Cat_Name2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                              ${len}

JD-TC-Get Stock Transfer Count Filter-17
    [Documentation]    Get Stock Transfer Count Filter using destinationInvCatalogId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationInvCatalogId-eq=${destinationInvCatalogId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationInvCatalogId-eq=${destinationInvCatalogId} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-18
    [Documentation]    Get Stock Transfer Count Filter using destinationInvCatalogEncId.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationInvCatalogEncId-eq=${Catalog_EncIds} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationInvCatalogEncId-eq=${Catalog_EncIds} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-19
    [Documentation]    Get Stock Transfer Count Filter using destinationInvCatalogName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     destinationInvCatalogName-eq=${INV_Cat_Name} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   destinationInvCatalogName-eq=${INV_Cat_Name} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}
JD-TC-Get Stock Transfer Count Filter-20
    [Documentation]    Get Stock Transfer Count Filter using transferDate and createdDate.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     transferDate-eq=${DAY1}  createdDate-eq==${DAY1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   transferDate-eq=${DAY1}  createdDate-eq==${DAY1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-21
    [Documentation]    Get Stock Transfer Count Filter using createdById and createdByName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     createdById-eq=${pid}   createdByName-eq=${pdrname} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   createdById-eq=${pid}   createdByName-eq=${pdrname} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}

JD-TC-Get Stock Transfer Count Filter-22
    [Documentation]    Get Stock Transfer Count Filter using updatedById and updatedByName.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     updatedById-eq=${pid}   updatedByName-eq=${pdrname} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   updatedById-eq=${pid}   updatedByName-eq=${pdrname} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-23
    [Documentation]    Get Stock Transfer Count Filter using updatedDate .


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     updatedDate-eq=${DAY1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   updatedDate-eq=${DAY1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-24
    [Documentation]    Get Stock Transfer Count Filter using verifiedByName .


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter     verifiedByName-eq=${pdrname}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   verifiedByName-eq=${pdrname}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-25
    [Documentation]    Get Stock Transfer Count Filter using verifiedDate .


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter    verifiedDate-eq=${DAY1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   verifiedDate-eq=${DAY1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-26
    [Documentation]    Get Stock Transfer Count Filter using transferType as new.


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter    transferType-eq=${status1[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   transferType-eq=${status1[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                               ${len}

JD-TC-Get Stock Transfer Count Filter-27
    [Documentation]    Get Stock Transfer Count Filter using transferStatus .


    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Stock TransferFilter    transferStatus-eq=${stockTransfer[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

    ${resp}=  Get Stock Transfer Count Filter   transferStatus-eq=${stockTransfer[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()}                                ${len}
