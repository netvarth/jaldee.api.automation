*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Auditlog 
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
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0

*** Test Cases ***

JD-TC-GetInvAuditlogByUid-1

    [Documentation]  Create inventory item, add item to inventory cataloge, then verify auditlogByUid.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.File Name
    Set Suite Variable  ${TypeName}
    sleep  02s
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.Last Name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.word
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}    ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${pid}          ${decrypted_data['id']}
    Set Suite Variable      ${pdrname}      ${decrypted_data['userName']}

    ${accountId}=  get_acc_id  ${PUSERNAME21}
    Set Suite Variable    ${accountId}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${user_id}  ${resp.json()[0]['id']}
    Set Suite Variable  ${user_firstName}  ${resp.json()[0]['firstName']}
    Set Suite Variable  ${user_lastName}  ${resp.json()[0]['lastName']}

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}

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

    ${Store_Name}=    FakerLibrary.last name
    Set Suite Variable    ${Store_Name} 
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Store_Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}
    

    #............create inventory item...............
    ${Catalog_Name}=    FakerLibrary.last name
    Set Suite Variable  ${Catalog_Name}
    ${resp}=  Create Inventory Catalog   ${Catalog_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['catalogName']}    ${Catalog_Name}
    Set Suite Variable  ${invCatalog_id}  ${resp.json()['id']}

    
    ${resp}=   Get Inventory Auditlog By Filter   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}     ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['subject']}            Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[0]['description']}        Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}             ${user_id}

    ${resp}=   Get Inventory Auditlog By Uid    ${encid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}     ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['subject']}            Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[0]['description']}        Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}             ${user_id}

JD-TC-GetInvAuditlogByUid-2

    [Documentation]  Update inventory cataloge, then verify auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Catalog_Name2}=    FakerLibrary.word
    Set Suite Variable    ${Catalog_Name2} 

    ${resp}=  Update Inventory Catalog   ${Catalog_Name2}  ${store_id}   ${encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['catalogName']}    ${Catalog_Name2}
    Should Be Equal As Strings    ${resp.json()['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['storeName']}    ${Store_Name}

    ${resp}=   Get Inventory Auditlog By Uid    ${encid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}     ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['subject']}            Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}        Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}             ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}     ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['subject']}            Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[1]['description']}        Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[1]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}             ${user_id}

JD-TC-GetInvAuditlogByUid-3

    [Documentation]  Update inventory catalog status, then verify auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Inventory Catalog status   ${encid}  ${InventoryCatalogStatus[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Uid    ${encid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}     ${InventoryAuditLogAction[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['subject']}            Inventory Catalog status updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}        Inventory Catalog ${Catalog_Name2} status updated to ${InventoryCatalogStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}             ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}     ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['subject']}            Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[1]['description']}        Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[1]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}             ${user_id}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}                ${encid}
    Should Be Equal As Strings  ${resp.json()[2]['auditType']}          ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditLogAction']}     ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['subject']}            Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[2]['description']}        Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[2]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['userId']}             ${user_id}

JD-TC-GetInvAuditlogByUid-4

    [Documentation]  Provider do the purchase then verify auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Inventory Catalog status   ${encid}  ${InventoryCatalogStatus[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Suite Variable    ${vender_name}

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

    ${nameit}=                        FakerLibrary.name
    ${shortDesc}=                   FakerLibrary.sentence
    ${internalDesc}=                FakerLibrary.sentence
    Set Suite Variable              ${nameit}
    Set Suite Variable              ${shortDesc}
    Set Suite Variable              ${internalDesc}

    ${resp}=    Create Item Inventory  ${nameit}  shortDesc=${shortDesc}   internalDesc=${internalDesc}    categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}    isBatchApplicable=${boolean[1]}  isInventoryItem=${boolean[1]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}   itemUnits=${itemUnits}  attachments=${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable              ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['name']}                                      ${nameit}
    Should Be Equal As Strings      ${resp.json()['shortDesc']}                                 ${shortDesc}
    Should Be Equal As Strings      ${resp.json()['internalDesc']}                              ${internalDesc}
    Should Be Equal As Strings      ${resp.json()['isInventoryItem']}                           ${bool[1]}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['categoryCode']}              ${categoryCode}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['categoryName']}              ${categoryName}
    Should Be Equal As Strings      ${resp.json()['itemCategory']['status']}                    ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['categoryCode']}           ${categoryCode}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['categoryName']}           ${categoryName}
    Should Be Equal As Strings      ${resp.json()['itemSubCategory']['status']}                 ${toggle[0]}
    Should Be Equal As Strings      ${resp.json()['itemGroups'][0]}                             ${ig_id}
    Should Be Equal As Strings      ${resp.json()['itemGroups'][1]}                             ${ig_id2}
    Should Be Equal As Strings      ${resp.json()['itemSubGroups'][0]}                          ${ig_id}
    Should Be Equal As Strings      ${resp.json()['itemSubGroups'][1]}                          ${ig_id2}
    Should Be Equal As Strings      ${resp.json()['tax'][0]}                                    ${itemtax_id}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${toggle[0]}

    ${resp}=   Create Inventory Catalog Item  ${encid}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_id}   ${resp.json()[0]}

    ${resp}=   Get Inventory Catalog item By EncId  ${ic_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${batch}=     FakerLibrary.name
    ${resp}=   Create Batch  ${store_id}   ${ic_id}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id1}  ${resp.json()['id']}

    ${quantity}=                    Random Int  min=1  max=99
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${freeQuantity}=                Random Int  min=0  max=10
    ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
    ${amount}=                      Random Int  min=10  max=999
    ${amount}=                      Convert To Number  ${amount}  1
    ${discountPercentage}=          Random Int  min=0  max=80
    ${discountPercentage}=          Convert To Number  ${discountPercentage}  1
    ${fixedDiscount}=               Random Int  min=0  max=10
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
    ${cgstamount_actual}=      Evaluate    ${taxableAmount} * ${cgst} / 100
    ${cgstamount}=               Convert To Number  ${cgstamount_actual}  2
    ${sgstamount_actual}=      Evaluate    ${taxableAmount} * ${sgst} / 100
    ${sgstamount}=               Convert To Number  ${sgstamount_actual}  2
    ${taxAmount}=       Evaluate    ${cgstamount_actual} + ${sgstamount_actual}
    ${taxAmount}=               Convert To Number  ${taxAmount}  2
    ${netRate}=         Evaluate    ${taxableAmount} + ${taxAmount}
    ${netRate}=               Convert To Number  ${netRate}  2
    Set Suite Variable              ${totalQuantity}
    Set Suite Variable              ${netTotal}
    Set Suite Variable              ${discountAmount}
    Set Suite Variable              ${taxableAmount}
    Set Suite Variable              ${cgstamount}
    Set Suite Variable              ${sgstamount}
    Set Suite Variable              ${taxAmount}
    Set Suite Variable              ${netRate}

    ${expiryDate}=  db.add_timezone_date  ${tz}  50
    ${sRate}=                   Evaluate                 ${amount} / ${convertionQty}
    ${salesRate}=               Evaluate                round(${sRate}, 2)
    ${totalAmount}=             Evaluate                ${amount} * ${quantity}
    ${invoiceDate}=             db.add_timezone_date    ${tz}  1
    ${rate}=                    Evaluate                int(${salesRate})
    ${mrp}=                     Random Int              min=${rate}  max=9999
    ${mrp}=                     Convert To Number  ${mrp}  1
    ${batchNo}=                 Random Int              min=1  max=9999
    ${invoiceReferenceNo}=      Random Int              min=1  max=999
    ${purchaseNote}=            FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=-10  max=10
    ${totalDiscountAmount}=     Evaluate                ${totalAmount} * ${discountPercentage} / 100
    ${totaltaxable}=            Evaluate                ${totalAmount} - ${totalDiscountAmount}
    ${totaltaxableamount}=      Evaluate                round(${totaltaxable}, 2)
    ${tcgst}=                   Evaluate                ${totaltaxableamount} * ${cgst} / 100
    ${totalcgst}=               Evaluate                round(${tcgst}, 2)
    ${tsgst}=                   Evaluate                ${totaltaxableamount} * ${sgst} / 100
    ${totalSgst}=               Evaluate                round(${tsgst}, 2)
    ${taxAmount}=               Evaluate                round(${taxAmount}, 2)
    Set Suite Variable          ${invoiceReferenceNo}
    Set Suite Variable          ${purchaseNote}
    Set Suite Variable          ${invoiceDate}
    Set Suite Variable          ${totaltaxableamount}
    Set Suite Variable          ${totalDiscountAmount}
    Set Suite Variable          ${totalSgst}
    Set Suite Variable          ${totalcgst}
    Set Suite Variable          ${totaltaxable}
    Set Suite Variable          ${totalAmount}
    Set Suite Variable          ${roundOff}
    Set Suite Variable          ${taxAmount}
    Set Suite Variable          ${mrp}
    Set Suite Variable          ${salesRate}
    Set Suite Variable          ${batchNo}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id}  ${quantity}  ${freeQuantity}  ${totalQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}    
    Set Suite Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${encid}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Suite Variable              ${purchaseId}           ${resp.json()}

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${purchase_EncId}           ${resp.json()['purchaseItemDtoList'][0]['encId']} 


    ${resp}=   Get Inventory Auditlog By Filter    account-eq=${accountId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200

    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Purchase created
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Purchase created for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Item Added to inventory Calatlog
    # Should Be Equal As Strings  ${resp.json()[1]['description']}    Item Added to inventory Calatlog ${Catalog_Name2} 
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}


    Should Be Equal As Strings  ${resp.json()[2]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[2]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditLogAction']}       ${InventoryAuditLogAction[3]} 
    Should Be Equal As Strings  ${resp.json()[2]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['subject']}    Inventory Catalog status updated
    Should Be Equal As Strings  ${resp.json()[2]['description']}    Inventory Catalog ${Catalog_Name2} status updated to ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings  ${resp.json()[2]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[3]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[3]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[3]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[3]['auditLogAction']}       ${InventoryAuditLogAction[3]} 
    Should Be Equal As Strings  ${resp.json()[3]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['subject']}    Inventory Catalog status updated
    Should Be Equal As Strings  ${resp.json()[3]['description']}    Inventory Catalog ${Catalog_Name2} status updated to ${InventoryCatalogStatus[1]}
    Should Be Equal As Strings  ${resp.json()[3]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[4]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[4]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[4]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[4]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[4]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[4]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[4]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[5]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[5]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[5]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[5]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[5]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[5]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[5]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[5]['userId']}   ${user_id}

    ${resp}=   Get Inventory Auditlog By Uid    ${purchaseId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Purchase created
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Purchase created for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByUid-5

    [Documentation]  Update purchase then verify auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${purchaseNote}=            FakerLibrary.Sentence
    ${roundOff}=                    Random Int  min=-10  max=10
    ${invoiceReferenceNo2}=          Random Int  min=1  max=999
    ${invoiceDate}=             db.add_timezone_date    ${tz}  1
    ${expiryDate}=  db.add_timezone_date  ${tz}  50

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id}  ${quantity}  ${freeQuantity}  ${totalQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}  encId=${purchase_EncId}


    ${resp}=    Update Purchase  ${purchaseId}  ${invoiceReferenceNo2}  ${invoiceDate}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()['invoiceReferenceNo']}      ${invoiceReferenceNo2}
    Should Be Equal As Strings      ${resp.json()['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()['vendor']['encId']}      ${vendorId}

    ${resp}=   Get Inventory Auditlog By Uid    ${purchaseId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Purchase updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Purchase updated for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Purchase created
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Purchase created for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByUid-6

    [Documentation]  Update purchase status then verify auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable      ${datetime1}    ${resp.json()}   
    ${datetime01}    Convert Date    ${datetime1}    result_format=%Y-%m-%d %H:%M
    Set Suite Variable      ${datetime01}

    ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[1]}
    Set Suite Variable  ${purchaseReferenceNo}  ${resp.json()['purchaseReferenceNo']}

    ${resp}=   Get Inventory Auditlog By Uid    ${purchaseId}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Purchase status updated       
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Purchase ${purchaseReferenceNo} status updated to ${PurchaseStatus[1]}  ignore_case=True
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}   
    Should Contain              ${resp.json()[0]['dateTime']}   ${datetime01} 

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Purchase updated
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Purchase updated for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[2]['uid']}       ${purchaseId}
    Should Be Equal As Strings  ${resp.json()[2]['auditType']}       ${InventoryAuditType[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[2]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['subject']}    Purchase created
    Should Be Equal As Strings  ${resp.json()[2]['description']}    Purchase created for ${vender_name} 
    Should Be Equal As Strings  ${resp.json()[2]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByUid-7

    [Documentation]  Provider add Remark then verifing with get auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remarks}=    FakerLibrary.name

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=   Get Inventory Auditlog By Uid    ${remarks_encid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${remarks_encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[3]} 
    # Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Remark Created
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Remark Created
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}   
    Should Contain              ${resp.json()[0]['dateTime']}   ${datetime01} 

JD-TC-GetInvAuditlogByUid-8

    [Documentation]  Provider Adjust the stock then verifing with get auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Catalog item By EncId  ${ic_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${datetime01}   ${resp.json()}  

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${ic_id} 
    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    batch=${batch_id1}    qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Stock_uid}  ${resp.json()}

    ${resp}=   Get Inventory Auditlog By Uid    ${Stock_uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${Stock_uid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Stock Adjusted
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Stock adjustment created 
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}   
    Should Contain              ${resp.json()[0]['dateTime']}   ${datetime01} 

JD-TC-GetInvAuditlogByUid-9

    [Documentation]  update the stock Adjusted then verifing with get auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${datetime01}   ${resp.json()}  

    ${resp}=  Update Stock Adjustment  ${Stock_uid}    ${locId1}  ${store_id}   ${encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Uid    ${Stock_uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${Stock_uid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Stock Adjusted
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Stock adjustment updated
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}   
    Should Contain              ${resp.json()[0]['dateTime']}   ${datetime01} 

    hould Be Equal As Strings  ${resp.json()[1]['uid']}       ${Stock_uid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Stock Adjusted
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Stock adjustment created 
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}   
    Should Contain              ${resp.json()[1]['dateTime']}   ${datetime01} 

JD-TC-GetInvAuditlogByUid-10

    [Documentation]  update the stock Adjusted then verifing with get auditlogByUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200