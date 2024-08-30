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
${order}        0
      



*** Test Cases ***

JD-TC-Get Stock Transfer By Uid-1
    [Documentation]    Get Stock Transfer using uid.
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
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+45085121
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

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}

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


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Suite Variable  ${place}  ${resp.json()['place']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Suite Variable  ${address}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}

# ------------------------ Create Source Store ----------------------------------------------------------

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
    Set Suite Variable  ${displayName1}

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable  ${itemSourceEnum1}  ${resp.json()['itemSourceEnum']}
    Set Suite Variable  ${itemPropertyType}  ${resp.json()['itemPropertyType']}

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

    ${quantity}=                    Random Int  min=1  max=999
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
    ${roundOff}=                    Random Int  min=1  max=5

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
# ------------------------ Create Destination Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Store_Name2}=    FakerLibrary.first name
    Set Suite Variable  ${Store_Name2}
    ${PhoneNumber2}=  Evaluate  ${PUSERNAME}+200187748
    Set Suite Variable  ${email_id}  ${Store_Name2}${PhoneNumber2}.${test_mail}
    ${email1}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name2}  ${St_Id}    ${locId1}  ${email1}     ${PhoneNumber2}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id2}  ${resp.json()}


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
    ${list}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=50
    ${items}=  Create List  ${list}
    ${resp}=  Create Stock Transfer   ${DAY1}  ${store_id}    ${store_id2}  ${Catalog_EncIds}     ${Catalog_EncIds2}  items=${items}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Stock_transfer_uid}  ${resp.json()['uid']}

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${Stock_transferItem_uid}                                   ${resp.json()['items'][0]['uid']}
    Set Suite Variable              ${destinationInvCatalogItem_uid}                                   ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}
    Should Be Equal As Strings      ${resp.json()['accountId']}                                 ${accountId}
    Should Be Equal As Strings      ${resp.json()['uid']}                                       ${Stock_transfer_uid}
    Should Be Equal As Strings      ${resp.json()['transferDate']}                              ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdDate']}                               ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdById']}                               ${pid}
    Should Be Equal As Strings      ${resp.json()['createdByName']}                             ${pdrname}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${stockTransfer[0]}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['name']}                       ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['encId']}                      ${store_id}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['name']}                  ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['encId']}                 ${store_id2}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['catalogName']}           ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['encId']}                 ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['catalogName']}      ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['encId']}            ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['sourceLocationId']}                          ${lid}
    Should Be Equal As Strings      ${resp.json()['sourceLocationName']}                        ${place}
    Should Be Equal As Strings      ${resp.json()['destinationLocationId']}                     ${lid}
    Should Be Equal As Strings      ${resp.json()['destinationLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['accountId']}                     ${accountId}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdById']}                   ${pid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdByName']}                 ${pdrname}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['name']}           ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['name']}           ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['encId']}          ${store_id2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['catalogName']}                   ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['encId']}                   ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['catalogName']}                   ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['encId']}                   ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalogItem']['encId']}                   ${ic_Item_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemSourceEnum']}                   ${itemSourceEnum1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['spCode']}                   ${item1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['name']}                   ${displayName1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemPropertyType']}                   ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()['items'][0]['transferQuantity']}                   50.0
    Should Be Equal As Strings      ${resp.json()['items'][0]['status']}                   ${donation_status[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationName']}                   ${place}

JD-TC-Get Stock Transfer By Uid-2
    [Documentation]    update stock transfer status then get stock transfer using uid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Update Stock Transfer Status   ${Stock_transfer_uid}  ${stockTransfer[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${Stock_transferItem_uid}                                   ${resp.json()['items'][0]['uid']}
    Set Suite Variable              ${destinationInvCatalogItem_uid}                                   ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}
    Should Be Equal As Strings      ${resp.json()['accountId']}                                 ${accountId}
    Should Be Equal As Strings      ${resp.json()['uid']}                                       ${Stock_transfer_uid}
    Should Be Equal As Strings      ${resp.json()['transferDate']}                              ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdDate']}                               ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdById']}                               ${pid}
    Should Be Equal As Strings      ${resp.json()['createdByName']}                             ${pdrname}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${stockTransfer[1]}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['name']}                       ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['encId']}                      ${store_id}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['name']}                  ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['encId']}                 ${store_id2}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['catalogName']}           ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['encId']}                 ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['catalogName']}      ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['encId']}            ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['sourceLocationId']}                          ${lid}
    Should Be Equal As Strings      ${resp.json()['sourceLocationName']}                        ${place}
    Should Be Equal As Strings      ${resp.json()['destinationLocationId']}                     ${lid}
    Should Be Equal As Strings      ${resp.json()['destinationLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['accountId']}                     ${accountId}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdById']}                   ${pid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdByName']}                 ${pdrname}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['name']}           ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['name']}           ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['encId']}          ${store_id2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['catalogName']}                   ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['encId']}                   ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['catalogName']}                   ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['encId']}                   ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalogItem']['encId']}                   ${ic_Item_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemSourceEnum']}                   ${itemSourceEnum1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['spCode']}                   ${item1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['name']}                   ${displayName1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemPropertyType']}                   ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()['items'][0]['transferQuantity']}                   50.0
    Should Be Equal As Strings      ${resp.json()['items'][0]['status']}                   ${donation_status[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationName']}                   ${place}

JD-TC-Get Stock Transfer By Uid-3
    [Documentation]    create stock transfer-(Batch enabled,Item is not in destination) and get transfer using id.
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Test Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Test Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+60015822
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    Log  ${resp.headers['Set-Cookie']}
    ${Sesioncookie}    ${rest}    Split String    ${resp.headers['Set-Cookie']}    ;  1
    ${cookie_parts}    ${jsessionynw_value}    Split String    ${Sesioncookie}    =
    Log   ${jsessionynw_value}

    ${resp}=    Account Activation  ${PUSERNAME_E}  ${OtpPurpose['ProviderSignUp']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=     Random Int  min=1111  max=9999
    Set Suite Variable      ${loginId}


    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Test Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Test Variable    ${pdrlname}    ${decrypted_data['lastName']}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${Test NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Test Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
    Set Test Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Test Variable  ${bs}

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${accountId}        ${resp.json()['id']}

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
    Set Test Variable  ${TypeName}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Provider Get Store Type ByEncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${place}  ${resp.json()['place']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Test Variable  ${address}
    Set Test Variable  ${postcode}
    Set Test Variable  ${city}

# ------------------------ Create Source Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1} 

    ${Store_Name1}=    FakerLibrary.first name
    Set Test Variable  ${Store_Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Store_Name1}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}   isBatchApplicable=${boolean[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${item1}  ${resp.json()}

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Source Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Catalog_EncIds}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Source Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable   ${ic_Item_id}   ${resp.json()[0]}

# -------------------------------------------------------------------------------------------------------------

    # ............... Create Vendor ...............

    ${resp}=  Populate Url For Vendor   ${account_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

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
    Set Test Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Test Variable    ${state}
    Set Test Variable    ${district}
    Set Test Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Test Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Test Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Test Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Test Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Test Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Test Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Test Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Test Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}                
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable      ${vendorId}     ${resp.json()['encId']}
# -----------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- Create itemUnits ------------------------------------------------------------------

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    Set Test Variable              ${unitName}
    Set Test Variable              ${convertionQty}

    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}


# --------------------------------------- Do the Purchase--------------------------------------------------------------

    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    Set Test Variable  ${quantity}

    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    Set Test Variable  ${freeQuantity}

    ${amount}=                      Random Int  min=1  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    Set Test Variable  ${amount}

    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    Set Test Variable  ${discountPercentage}

    ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    Set Test Variable  ${fixedDiscount}

    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity} 
    ${totalQuantity}=   Evaluate    ${totalQuantity} * ${convertionQty}
    Set Test Variable  ${totalQuantity}

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
    ${roundOff}=                    Random Int  min=1  max=5

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList   ${ic_Item_id}   ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}
    Set Test Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${Catalog_EncIds}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Test Variable              ${purchaseId}           ${resp.json()}

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




# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# -----------------------------------------------------------------------------------
# ------------------------ Create Destination Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1} 

    ${Store_Name2}=    FakerLibrary.first name
    Set Test Variable  ${Store_Name2}
    ${PhoneNumber2}=  Evaluate  ${PUSERNAME}+200187748
    Set Test Variable  ${email_id}  ${Store_Name2}${PhoneNumber2}.${test_mail}
    ${email1}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name2}  ${St_Id}    ${locId1}  ${email1}     ${PhoneNumber2}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id2}  ${resp.json()}


# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Destination Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name2}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name2}  ${store_id2}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Catalog_EncIds2}  ${resp.json()}



# -------------------------------------------Create Store Transfer-----------------------------------------------------------------
    ${sourceInvCatalogItem}=  Create Dictionary  encId=${ic_Item_id}  
    ${sourceInvItemBatch}=  Create Dictionary  batch=${batchNo}  
    ${list}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=50   sourceInvItemBatch=${sourceInvItemBatch}
    ${items}=  Create List  ${list}
    ${resp}=  Create Stock Transfer   ${DAY1}  ${store_id}    ${store_id2}  ${Catalog_EncIds}     ${Catalog_EncIds2}  items=${items}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Stock_transfer_uid}  ${resp.json()['uid']}

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${Stock_transferItem_uid}                                   ${resp.json()['items'][0]['uid']}
    Set Test Variable              ${destinationInvCatalogItem_uid}                                   ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}
    Should Be Equal As Strings      ${resp.json()['accountId']}                                 ${accountId}
    Should Be Equal As Strings      ${resp.json()['uid']}                                       ${Stock_transfer_uid}
    Should Be Equal As Strings      ${resp.json()['transferDate']}                              ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdDate']}                               ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdById']}                               ${pid}
    Should Be Equal As Strings      ${resp.json()['createdByName']}                             ${pdrname}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${stockTransfer[0]}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['name']}                       ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['encId']}                      ${store_id}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['name']}                  ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['encId']}                 ${store_id2}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['catalogName']}           ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['encId']}                 ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['catalogName']}      ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['encId']}            ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['sourceLocationId']}                          ${lid}
    Should Be Equal As Strings      ${resp.json()['sourceLocationName']}                        ${place}
    Should Be Equal As Strings      ${resp.json()['destinationLocationId']}                     ${lid}
    Should Be Equal As Strings      ${resp.json()['destinationLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['accountId']}                     ${accountId}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdById']}                   ${pid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdByName']}                 ${pdrname}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['name']}           ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['encId']}          ${store_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['name']}           ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['encId']}          ${store_id2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['catalogName']}                   ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['encId']}                   ${Catalog_EncIds}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['catalogName']}                   ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['encId']}                   ${Catalog_EncIds2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalogItem']['encId']}                   ${ic_Item_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemSourceEnum']}                   ${itemSourceEnum1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['spCode']}                   ${item1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['name']}                   ${displayName1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemPropertyType']}                   ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()['items'][0]['transferQuantity']}                   50.0
    Should Be Equal As Strings      ${resp.json()['items'][0]['status']}                   ${donation_status[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationName']}                   ${place}

JD-TC-Get Stock Transfer By Uid-4
    [Documentation]    update stock transfer then get stock transfer using uid

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Test Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Test Variable  ${lastname_A}
    ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+40082215
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_F}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_F}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_F}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Test Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Test Variable    ${pdrlname}    ${decrypted_data['lastName']}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_F}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${Test NAME} - ${TEST NAME} - ${PUSERNAME_F}${\n}
    Set Suite Variable  ${PUSERNAME_F}
    ${id}=  get_id  ${PUSERNAME_F}
    Set Test Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Test Variable  ${bs}

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${accountId}        ${resp.json()['id']}

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
    Set Test Variable  ${TypeName}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Provider Get Store Type ByEncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${place}  ${resp.json()['place']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Test Variable  ${address}
    Set Test Variable  ${postcode}
    Set Test Variable  ${city}

# ------------------------ Create Source Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1} 

    ${Store_Name1}=    FakerLibrary.first name
    Set Test Variable  ${Store_Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Store_Name1}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id3}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${item1}  ${resp.json()}

# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Source Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id3}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds3}  ${resp.json()}
# ------------------------------------------------------------------------------------------------------------

# ----------------------------------------Create Source Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds3}   ${item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable   ${ic_Item_id}   ${resp.json()[0]}

# -------------------------------------------------------------------------------------------------------------

    # ............... Create Vendor ...............

    ${resp}=  Populate Url For Vendor   ${account_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

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
    Set Test Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Test Variable    ${state}
    Set Test Variable    ${district}
    Set Test Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Test Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Test Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Test Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Test Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Test Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Test Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Test Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Test Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}                
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable      ${vendorId}     ${resp.json()['encId']}
# -----------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- Create itemUnits ------------------------------------------------------------------

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    Set Test Variable              ${unitName}
    Set Test Variable              ${convertionQty}

    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}


# --------------------------------------- Do the Purchase--------------------------------------------------------------

    ${quantity}=                    Random Int  min=0  max=999
    ${quantity}=                    Convert To Number  ${quantity}  1
    Set Test Variable  ${quantity}

    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    Set Test Variable  ${freeQuantity}

    ${amount}=                      Random Int  min=1  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    Set Test Variable  ${amount}

    ${discountPercentage}=          Random Int  min=0  max=100
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    Set Test Variable  ${discountPercentage}

    ${fixedDiscount}=               Random Int  min=0  max=200
    ${fixedDiscount}=               Convert To Number  ${fixedDiscount}  1
    Set Test Variable  ${fixedDiscount}

    ${totalQuantity}=   Evaluate    ${quantity} + ${freeQuantity} 
    ${totalQuantity}=   Evaluate    ${totalQuantity} * ${convertionQty}
    Set Test Variable  ${totalQuantity}

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
    Set Test Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id3}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${Catalog_EncIds3}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Test Variable              ${purchaseId}           ${resp.json()}

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
    Set Test Variable  ${DAY1} 

    ${Store_Name2}=    FakerLibrary.first name
    Set Test Variable  ${Store_Name2}
    ${PhoneNumber2}=  Evaluate  ${PUSERNAME}+200187748
    Set Test Variable  ${email_id}  ${Store_Name2}${PhoneNumber2}.${test_mail}
    ${email1}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name2}  ${St_Id}    ${locId1}  ${email1}     ${PhoneNumber2}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id4}  ${resp.json()}


# ------------------------------------------------------------------------------------------------------

# ----------------------------------------- create Destination Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name2}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name2}  ${store_id4}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds4}  ${resp.json()}



# -------------------------------------------Create Store Transfer-----------------------------------------------------------------
    ${sourceInvCatalogItem}=  Create Dictionary  encId=${ic_Item_id}  
    ${list}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=50
    ${items}=  Create List  ${list}
    ${resp}=  Create Stock Transfer   ${DAY1}  ${store_id3}    ${store_id4}  ${Catalog_EncIds3}     ${Catalog_EncIds4}  items=${items}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Stock_transfer_uid1}  ${resp.json()['uid']}

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${Stock_transferItem_uid1}                                   ${resp.json()['items'][0]['uid']}
    Set Test Variable              ${destinationInvCatalogItem_uid}                                   ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}

    ${list1}=  Create Dictionary  sourceInvCatalogItem=${sourceInvCatalogItem}    transferQuantity=55   uid=${Stock_transferItem_uid1}
    ${items1}=  Create List  ${list1}
    Set Suite Variable  ${items1} 

    ${resp}=  Update Stock Transfer   ${Stock_transfer_uid1}   ${DAY1}  ${store_id3}    ${store_id4}  ${Catalog_EncIds3}     ${Catalog_EncIds4}  items=${items1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['accountId']}                                 ${accountId}
    Should Be Equal As Strings      ${resp.json()['uid']}                                       ${Stock_transfer_uid1}
    Should Be Equal As Strings      ${resp.json()['transferDate']}                              ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdDate']}                               ${DAY1}
    Should Be Equal As Strings      ${resp.json()['createdById']}                               ${pid}
    Should Be Equal As Strings      ${resp.json()['createdByName']}                             ${pdrname}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${stockTransfer[0]}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['name']}                       ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['sourceStore']['encId']}                      ${store_id3}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['name']}                  ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationStore']['encId']}                 ${store_id4}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['catalogName']}           ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['sourceInvCatalog']['encId']}                 ${Catalog_EncIds3}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['catalogName']}      ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['destinationInvCatalog']['encId']}            ${Catalog_EncIds4}
    Should Be Equal As Strings      ${resp.json()['sourceLocationId']}                          ${lid}
    Should Be Equal As Strings      ${resp.json()['sourceLocationName']}                        ${place}
    Should Be Equal As Strings      ${resp.json()['destinationLocationId']}                     ${lid}
    Should Be Equal As Strings      ${resp.json()['destinationLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['accountId']}                     ${accountId}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdById']}                   ${pid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['createdByName']}                 ${pdrname}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['name']}           ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceStore']['encId']}          ${store_id3}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['name']}           ${Store_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['onlineOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['walkinOrder']}    ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['partnerOrder']}   ${bool[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationStore']['encId']}          ${store_id4}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['catalogName']}                   ${INV_Cat_Name}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalog']['encId']}                   ${Catalog_EncIds3}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['catalogName']}                   ${INV_Cat_Name2}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalog']['encId']}                   ${Catalog_EncIds4}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceInvCatalogItem']['encId']}                   ${ic_Item_id}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemSourceEnum']}                   ${itemSourceEnum1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['spCode']}                   ${item1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['name']}                   ${displayName1}
    Should Be Equal As Strings      ${resp.json()['items'][0]['spItem']['itemPropertyType']}                   ${itemPropertyType}
    Should Be Equal As Strings      ${resp.json()['items'][0]['transferQuantity']}                   55.0
    Should Be Equal As Strings      ${resp.json()['items'][0]['status']}                   ${donation_status[0]}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['sourceLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationId']}                   ${lid}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationLocationName']}                   ${place}
    Should Be Equal As Strings      ${resp.json()['items'][0]['destinationInvCatalogItem']['encId']}            ${destinationInvCatalogItem_uid} 

JD-TC-Get Stock Transfer By Uid-UH1
    [Documentation]     get stock transfer by uid  without login

    ${resp}=  Get Stock Transfer By Uid   ${Stock_transfer_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  ${resp.json()}    ${SESSION_EXPIRED} 













