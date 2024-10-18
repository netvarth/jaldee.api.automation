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
${invalidNum}       1245
${invalidEma}       asd122
${invalidstring}    _ad$.sa_
${invalidItem}      sprx-3250dr0-800
@{spItemSource}     RX       Ayur
${originFrom}       NONE
@{deliveryType}     STORE_PICKUP        HOME_DELIVERY
      
*** Test Cases ***

JD-TC-GetOrderByFilter-1

    [Documentation]    Get Order By Filter

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
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+4448754
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

    Set Suite Variable    ${pid}  ${decrypted_data['id']}
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

    ${doc1}=  Create Sample User 
    Set Suite Variable      ${doc1}

    ${resp}=  Get User By Id  ${doc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}
    Set Suite Variable  ${Docfname}  ${resp.json()['firstName']}
    Set Suite Variable  ${Doclname}  ${resp.json()['lastName']}
     
    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${accountId}=  get_acc_id  ${HLPUSERNAME16}
    # Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Suite Variable  ${address}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${city}

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Store_Name1}=    FakerLibrary.first name
    Set Suite Variable      ${Store_Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${email_id}  ${PhoneNumber}${Store_Name1}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name1}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}


# ----------------------------------------  Create Item ---------------------------------------------

    ${displayName1}=        FakerLibrary.name
    Set Suite Variable      ${displayName1}

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}  isBatchApplicable=${boolean[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}

    ${displayName2}=        FakerLibrary.name
    Set Suite Variable      ${displayName2}

    ${resp}=    Create Item Inventory  ${displayName2}    isInventoryItem=${bool[1]}  isBatchApplicable=${boolean[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item2}  ${resp.json()}


# ----------------------------------------- create Inv Catalog -------------------------------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}

# ----------------------------------------Create Inventory Catalog Item----------------------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${item1}  ${item2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Item_id}   ${resp.json()[0]}

    ${resp}=   Get Inventory Catalog item By EncId  ${ic_Item_id} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

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

# ------------------------------------------- Check Stock ---------------------------------------------------
    ${resp}=    Get Stock Avaliability  ${ic_Item_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
# -----------------------------------------------------------------------------------

# -------------------------------- Add a provider Consumer -----------------------------------


    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   FakerLibrary.first_name
    ${lastName}=    FakerLibrary.last_name
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}${firstName}.${test_mail}

    ${resp}=  AddCustomer  ${primaryMobileNo}  firstName=${firstName}   lastName=${lastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${email}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${primaryMobileNo}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullastName}   Set Variable    ${firstName} ${lastName}
    Set Test Variable  ${fullastName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
    
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Consumer Logout 
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

    ${frequency}=       Random Int  min=26  max=30
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

    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
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

    ${resp}=    Get RX Prescription By Id  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${RDID1}      ${resp.json()['id']}

    ${dur2}=        Random Int  min=1  max=100
    ${qt2}=        Random Int  min=1  max=10
    ${duration2}=             Evaluate    float(${dur2})
    ${quantity2}=             Evaluate    float(${qt2})
    Set Suite Variable      ${duration2}
    Set Suite Variable      ${quantity2}

    ${resp}=    RX Create Prescription Item  ${displayName2}  ${duration2}  ${quantity2}  ${description}  ${item2}  ${dos}  ${frequency_id}  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable              ${pitm_id}      ${resp.json()}

    ${resp}=    Get RX Prescription Item By EncId  ${pitm_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                         200 
    Set Suite Variable              ${RDID2}      ${resp.json()['id']}

    ${itemqty}=    Evaluate   ${dos} * ${duration2}

    ${resp}=    Get RX Prescription Item Qnty By EncId  ${displayName2}  ${duration2}  ${quantity2}  ${description}  ${item2}  ${dos}  ${frequency_id}  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()}          ${itemqty}

    ${resp}=    Order Request    ${store_id}  ${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200

    ${resp}=    Get Sorder By Filter  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable      ${sorder_uid}   ${resp.json()[0]['uid']}
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

    ${resp}=    Get Sorder By Uid  ${sorder_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable              ${refNumber}      ${resp.json()['store']['refNumber']}
    Set Suite Variable              ${presc_ref}    ${resp.json()['prescriptionRefNo']}
    Set Suite Variable              ${orgin_From}   ${resp.json()['originFrom']}

JD-TC-GetOrderByFilter-2

    [Documentation]    Get Order By Filter - account

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter      account-eq=${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-3

    [Documentation]    Get Order By Filter - uid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter      uid-eq=${sorder_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-4

    [Documentation]    Get Order By Filter -  locationId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       locationId-eq=${locId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-5

    [Documentation]    Get Order By Filter -  storeId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       storeEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-6

    [Documentation]    Get Order By Filter -  storeName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       storeName-eq=${Store_Name1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-7

    [Documentation]    Get Order By Filter -  storeRefNo

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       storeRefNo-eq=${refNumber}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-8

    [Documentation]    Get Order By Filter -  acceptedBy

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       acceptedBy-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200

JD-TC-GetOrderByFilter-9

    [Documentation]    Get Order By Filter -  originFrom

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       originFrom-eq=${orgin_From}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-10

    [Documentation]    Get Order By Filter -   prescriptionUid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        prescriptionUid-eq=${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-11

    [Documentation]    Get Order By Filter -   prescriptionRefNo

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        prescriptionRefNo-eq=${presc_ref}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-12

    [Documentation]    Get Order By Filter -   prescriptionUid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        prescriptionUid-eq=${prescription_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-13

    [Documentation]    Get Order By Filter -   prescriptionDate

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        prescriptionDate-eq=${DAY1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-14

    [Documentation]    Get Order By Filter -   doctorId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        doctorId-eq=${doc1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-15

    [Documentation]    Get Order By Filter -   doctorName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        doctorName-eq=${Docfname} ${Doclname}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-16

    [Documentation]    Get Order By Filter -   orderStatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        orderStatus-eq=${couponState[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-17

    [Documentation]    Get Order By Filter -   pushedStatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        pushedStatus-eq=${pushedStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-18

    [Documentation]    Get Order By Filter -   providerConsumerId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        providerConsumerId-eq=${cid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-19

    [Documentation]    Get Order By Filter -   providerConsumerName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        providerConsumerName-eq=${firstName} ${lastName}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['createdBy']}    ${pid}
    Should Be Equal As Strings      ${resp.json()[0]['createdByName']}    ${pdrname}
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}    ${Store_Name1}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionUid']}    ${prescription_id}
    Should Be Equal As Strings      ${resp.json()[0]['prescriptionDate']}    ${DAY1}
    Should Be Equal As Strings      ${resp.json()[0]['pushedStatus']}    ${pushedStatus[0]}
    Should Be Equal As Strings      ${resp.json()[0]['doctorId']}    ${doc1}
    Should Be Equal As Strings      ${resp.json()[0]['doctorName']}    ${Docfname} ${Doclname}
    Should Be Equal As Strings      ${resp.json()[0]['orderStatus']}    ${couponState[0]}

JD-TC-GetOrderByFilter-20 

    [Documentation]    Get Order By Filter -  acceptedDate

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter       acceptedDate-eq=${DAY1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200


# JD-TC-GetOrderByFilter-UH1-----DEV not take given accountId ,they are took correct accountid 

#     [Documentation]    Get Order By Filter - invalid account

#     ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
#     Log  ${resp.json()}         
#     Should Be Equal As Strings            ${resp.status_code}    200

#     ${inv}=     Random int  min=10000  max=15000

#     ${resp}=    Get Sorder By Filter      account-eq=${inv}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}             200
#     Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH2

    [Documentation]    Get Order By Filter - invalid uid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random int  min=666  max=999

    ${resp}=    Get Sorder By Filter      uid-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH3

    [Documentation]    Get Order By Filter -  invalid locationId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random int  min=666  max=999

    ${resp}=    Get Sorder By Filter       locationId-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH4

    [Documentation]    Get Order By Filter -  invalid storeId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random int  min=666  max=999

    ${resp}=    Get Sorder By Filter       storeEncId-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH5

    [Documentation]    Get Order By Filter -  invalid storeName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${ran_name}=    generate_firstname

    ${resp}=    Get Sorder By Filter       storeName-eq=${ran_name}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH6

    [Documentation]    Get Order By Filter -  invalid storeRefNo

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=333  max=999

    ${resp}=    Get Sorder By Filter       storeRefNo-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH7

    [Documentation]    Get Order By Filter -  invalid acceptedBy

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${ran_name}=    generate_firstname
    ${resp}=    Get Sorder By Filter       acceptedBy-eq=${ran_name}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

# JD-TC-GetOrderByFilter-UH8

#     [Documentation]    Get Order By Filter -  invalid originFrom

#     ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
#     Log  ${resp.json()}         
#     Should Be Equal As Strings            ${resp.status_code}    200

#     ${inv_orgin}=   generate_firstname

#     ${resp}=    Get Sorder By Filter       originFrom-eq=${inv_orgin}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}             200
#     Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH9

    [Documentation]    Get Order By Filter -   invalid prescriptionUid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${resp}=    Get Sorder By Filter        prescriptionUid-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH10

    [Documentation]    Get Order By Filter -   invalid prescriptionRefNo

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${resp}=    Get Sorder By Filter        prescriptionRefNo-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH11

    [Documentation]    Get Order By Filter -   invalid prescriptionUid

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${resp}=    Get Sorder By Filter        prescriptionUid-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH12

    [Documentation]    Get Order By Filter -   invalid prescriptionDate

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${day2}=   db.Add Date  10

    ${resp}=    Get Sorder By Filter        prescriptionDate-eq=${day2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH13

    [Documentation]    Get Order By Filter -  invalid doctorId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

     ${inv}=     Random Int  min=111  max=999

    ${resp}=    Get Sorder By Filter        doctorId-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH14

    [Documentation]    Get Order By Filter -   invalid doctorName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${ran_name}=    generate_firstname

    ${resp}=    Get Sorder By Filter        doctorName-eq=${ran_name}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

# JD-TC-GetOrderByFilter-UH15

#     [Documentation]    Get Order By Filter -   invalid orderStatus

#     ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
#     Log  ${resp.json()}         
#     Should Be Equal As Strings            ${resp.status_code}    200

#     ${resp}=    Get Sorder By Filter        orderStatus-eq=${couponState[1]}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}             200
#     Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH16

    [Documentation]    Get Order By Filter -   invalid pushedStatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sorder By Filter        pushedStatus-eq=${pushedStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH17

    [Documentation]    Get Order By Filter -   invalid providerConsumerId

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${inv}=     Random Int  min=111  max=999

    ${resp}=    Get Sorder By Filter        providerConsumerId-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH18

    [Documentation]    Get Order By Filter -   invalid providerConsumerName

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${ran_name}=    generate_firstname

    ${resp}=    Get Sorder By Filter        providerConsumerName-eq=${ran_name}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH19

    [Documentation]    Get Order By Filter -  invalid acceptedDate

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${resp}=    Get Sorder By Filter       acceptedDate-eq=${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should BeEqual As Strings     ${resp.json()}      []

JD-TC-GetOrderByFilter-UH20

    [Documentation]    Get Order By Filter -  without login

    ${resp}=    Get Sorder By Filter       acceptedDate-eq=${DAY1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}        419
    Should Be Equal As Strings      ${resp.json()}             ${SESSION_EXPIRED}