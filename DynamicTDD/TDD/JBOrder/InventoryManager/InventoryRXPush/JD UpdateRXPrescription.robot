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
      
*** Test Cases ***

JD-TC-UpdatePrescription-1

    [Documentation]    Update Prescription

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
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+45778121
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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

    ${doc1}=  Create Sample User 
    Set Suite Variable      ${doc1}

    ${resp}=  Get User By Id  ${doc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}
    Set Suite Variable  ${Docfname}  ${resp.json()['firstName']}
    Set Suite Variable  ${Doclname}  ${resp.json()['lastName']}
     
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
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${email_id}  ${Store_Name1}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}


# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}


# ----------------------------------------- create Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Item_id}   ${resp.json()[0]}


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

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList   ${ic_Item_id}   ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}   ${iu_id}
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
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
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

    ${Store_note}=  FakerLibrary.name
    ${inv_cat_encid_List}=  Create List  ${Catalog_EncIds}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Store_note}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}
# ---------------------------------------------------------------------------------------------------------
# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_Item_id}     ${price}    ${boolean[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${frequency}=       Random Int  min=106  max=110
    ${dosage}=          Random Int  min=1  max=3000
    ${description}=     FakerLibrary.sentence
    ${remark}=          FakerLibrary.sentence
    ${dos}=             Evaluate    float(${dosage})
    Set Suite Variable      ${frequency}
    Set Suite Variable      ${dosage}
    Set Suite Variable      ${description}
    Set Suite Variable      ${remark}
    Set Suite Variable      ${dos}

    ${resp}=    Create Frequency  ${frequency}  ${dosage}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['id']}            ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['frequency']}     ${frequency}
    Should Be Equal As Strings      ${resp.json()['description']}   ${description}
    Should Be Equal As Strings      ${resp.json()['remark']}        ${remark}
    Should Be Equal As Strings      ${resp.json()['dosage']}        ${dos}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventoryRx']}==${bool[0]}
        ${resp1}=  Enable/Disable Inventory Rx  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[1]}
    END

    ${dur}=        Random Int  min=1  max=100
    ${qt}=        Random Int  min=1  max=10
    ${duration1}=             Evaluate    float(${dur})
    ${quantity1}=             Evaluate    float(${qt})
    Set Suite Variable      ${duration1}
    Set Suite Variable      ${quantity1}

    ${resp}=    RX Create Prescription  ${cid}  ${doc1}  ${displayName1}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${prescription_id}      ${resp.json()}

    ${prescriptionCreatedDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable          ${prescriptionCreatedDate}

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${displayName1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}


    ${medicineName2}=    FakerLibrary.firstName
    Set Suite Variable      ${medicineName2}

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}


JD-TC-UpdatePrescription-2

    [Documentation]    Update Prescription - prescription id is invalid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=99  max=999

    ${PRESCRIPTION_NOT_FOUND}=  Format String    ${PRESCRIPTION_NOT_FOUND}    ${inv}

    ${resp}=    RX Update Prescription  ${inv}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${PRESCRIPTION_NOT_FOUND}


JD-TC-UpdatePrescription-3

    [Documentation]    Update Prescription - Provider consumer id is invalid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=99  max=999

    ${resp}=    RX Update Prescription  ${prescription_id}  ${inv}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${CONSUMER_NOT_FOUND}

JD-TC-UpdatePrescription-4

    [Documentation]    Update Prescription - Provider consumer id is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${empty}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_PROVIDERCONSUMER_ID}

JD-TC-UpdatePrescription-5

    [Documentation]    Update Prescription - invalid doc id

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=99  max=999

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${inv}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_USER_ID}

JD-TC-UpdatePrescription-6

    [Documentation]    Update Prescription - doc id is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${empty}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_Doctor_ID}

JD-TC-UpdatePrescription-7

    [Documentation]    Update Prescription - medicine name is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${empty}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${empty}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-8

    [Documentation]    Update Prescription - medicine name is changed

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${medicineName_ran}=     FakerLibrary.name

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName_ran}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName_ran}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-9

    [Documentation]    Update Prescription - duration is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${empty}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_DURATION_VALUE}


    # ${resp}=    Get RX Prescription By Id  ${prescription_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}     200
    # Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    # Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    # Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    # Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    # Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    # Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    # Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    # Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-10

    [Documentation]    Update Prescription - duration is changed

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=     Random Int  min=99  max=999
    ${inv}=             Evaluate    float(${invalid})

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${inv}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}  
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${inv}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}


JD-TC-UpdatePrescription-11

    [Documentation]    Update Prescription - quantity is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${empty}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_QUANTITY_VALUE}


    # ${resp}=    Get RX Prescription By Id  ${prescription_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}     200
    # Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    # Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    # Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    # Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    # Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    # Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    # Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    # Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    # Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${empty}
    # Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-12

    [Documentation]    Update Prescription - quantity is changed

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=     Random Int  min=99  max=999
    ${inv}=             Evaluate    float(${invalid})

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${inv}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${inv}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}


JD-TC-UpdatePrescription-13

    [Documentation]    Update Prescription - description is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${empty}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${empty}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-14

    [Documentation]    Update Prescription - description is changed

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${des}=     FakerLibrary.sentence

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${des}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${des}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-15

    [Documentation]    Update Prescription - item code is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${empty}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${empty}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}


JD-TC-UpdatePrescription-16

    [Documentation]    Update Prescription - item code is invalid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=99  max=999

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${inv}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${inv}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${dos}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-17

    [Documentation]    Update Prescription - dosage is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${empty}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_DOSAGE_VALUE}


JD-TC-UpdatePrescription-18

    [Documentation]    Update Prescription - dosage is chamged

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=     Random Int  min=99  max=999
    ${inv}=             Evaluate    float(${invalid})

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${inv}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['providerConsumerId']}                                ${cid}
    Should Be Equal As Strings      ${resp.json()['doctorId']}                                          ${doc1}
    Should Be Equal As Strings      ${resp.json()['uid']}                                               ${prescription_id}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedDate']}                           ${prescriptionCreatedDate}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedBy']}                             ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionCreatedByName']}                         ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['owner']}               ${pid}
    Should Be Equal As Strings      ${resp.json()['prescriptionAttachments'][0]['ownerName']}           ${pdrname}
    Should Be Equal As Strings      ${resp.json()['prescriptionStatus']}                                ${printTemplateStatus[0]}
    Should Be Equal As Strings      ${resp.json()['prescriptionSharedStatus']}                          ${prescriptionSharedStatus[1]}
    Should Be Equal As Strings      ${resp.json()['doctorName']}                                        ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['spItemCode']}          ${item1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['medicineName']}        ${medicineName2}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['duration']}            ${duration1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['frequency']['id']}     ${frequency_id}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['dosage']}              ${inv}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['description']}         ${description}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['quantity']}            ${quantity1}
    Should Be Equal As Strings      ${resp.json()['mrPrescriptionItemsDtos'][0]['prescriptioinUid']}    ${prescription_id}

JD-TC-UpdatePrescription-19

    [Documentation]    Update Prescription - frequency is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${empty}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_FREEQUENCY_VALUE}
    

JD-TC-UpdatePrescription-20

    [Documentation]    Update Prescription - frequency is invalid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=99  max=999

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${inv}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings      ${resp.json()}          ${INVALID_FREEQUENCY_VALUE}



JD-TC-UpdatePrescription-21

    [Documentation]    Update Prescription - html is empty

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        422
    Should Be Equal As Strings      ${resp.json()}             ${HTML_REQUIRED}

JD-TC-UpdatePrescription-22

    [Documentation]    Update Prescription - without login

    ${resp}=    RX Update Prescription  ${prescription_id}  ${cid}  ${doc1}  ${medicineName2}  ${duration1}  ${quantity1}  ${description}  ${item1}  ${dos}  ${frequency_id}  ${html}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        419
    Should Be Equal As Strings      ${resp.json()}             ${SESSION_EXPIRED}