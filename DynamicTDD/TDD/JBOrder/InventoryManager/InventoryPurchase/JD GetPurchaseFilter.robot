*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PURCHASE 
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
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0

*** Test Cases ***

JD-TC-GetPurchaseByFilter-1
    [Documentation]  Get Purchase By Filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

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
        Set Suite Variable  ${place}    ${resp.json()[0]['place']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
        Set Suite Variable  ${place}    ${resp.json()[0]['place']}
    END

    ${SName}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${SName}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Suite Variable      ${SName}

    ${resp}=  Create Store   ${SName}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
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
    Set Suite Variable      ${vender_name}

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

    ${nameit}=                        FakerLibrary.name
    ${shortDesc}=                   FakerLibrary.sentence
    ${internalDesc}=                FakerLibrary.sentence
    Set Suite Variable              ${nameit}
    Set Suite Variable              ${shortDesc}
    Set Suite Variable              ${internalDesc}

    ${resp}=    Create Item Inventory  ${nameit}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[1]}  isInventoryItem=${boolean[1]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable              ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemCode']}                  ${itemjrx}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['itemName']}                  ${itemName}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['description']}               ${description}
    Should Be Equal As Strings      ${resp.json()['jaldeeRxCode']['sku']}                       ${sku}
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
    Should Be Equal As Strings      ${resp.json()['composition'][0]}                            ${compositionCode}
    Should Be Equal As Strings      ${resp.json()['sku']}                                       ${sku}
    Should Be Equal As Strings      ${resp.json()['itemUnits'][0]}                              ${iu_id}
    Should Be Equal As Strings      ${resp.json()['isBatchApplicable']}                         ${bool[1]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileName']}                ${jpgfile}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileSize']}                ${fileSize}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['fileType']}                ${fileType}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['order']}                   ${order}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['action']}                  ${file_action[0]}
    Should Be Equal As Strings      ${resp.json()['attachments'][0]['driveId']}                 ${driveId}
    Should Be Equal As Strings      ${resp.json()['status']}                                    ${toggle[0]}

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

    ${resp}=    Get Item Details Inventory  ${store_id}  ${vendorId}  ${inventoryCatalogItem}  ${quantity}  ${freeQuantity}   ${amount}  ${fixedDiscount}  ${discountPercentage}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                     200
    Should Be Equal As Strings      ${resp.json()['quantity']}              ${quantity}
    Should Be Equal As Strings      ${resp.json()['freeQuantity']}          ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()['totalQuantity']}         ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()['amount']}                ${amount}
    Should Be Equal As Strings      ${resp.json()['discountPercentage']}    ${discountPercentage}
    Should Be Equal As Strings      ${resp.json()['discountAmount']}        ${discountAmount}
    Should Be Equal As Strings      ${resp.json()['taxableAmount']}         ${taxableAmount}
    Should Be Equal As Strings      ${resp.json()['cgstPercentage']}        ${cgst}
    Should Be Equal As Strings      ${resp.json()['sgstPercentage']}        ${sgst}
    Should Be Equal As Strings      ${resp.json()['cgst']}                  ${cgstamount}
    Should Be Equal As Strings      ${resp.json()['sgst']}                  ${sgstamount}
    Should Be Equal As Strings      ${resp.json()['taxPercentage']}         ${taxPercentage}
    Should Be Equal As Strings      ${resp.json()['taxAmount']}             ${taxAmount}
    Should Be Equal As Strings      ${resp.json()['netTotal']}              ${netTotal}
    Should Be Equal As Strings      ${resp.json()['netRate']}               ${netRate}

    ${inv_cat_encid_List}=  Create List  ${encid}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1
    Set Suite Variable  ${price}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_id}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${expiryDate}=  db.add_timezone_date  ${tz}  50
    Set Suite Variable          ${expiryDate}

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
    ${roundOff}=                Random Int              min=1  max=10
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

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id}  ${quantity}  ${freeQuantity}  ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}    
    Set Suite Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${encid}  ${purchaseNote}  ${roundOff}  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Suite Variable              ${purchaseId}           ${resp.json()}

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()['totalSgst']}      ${totalSgst}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['inventoryCatalogItem']['encId']}      	${ic_id}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['inventoryCatalogItem']['item']['name']}      ${nameit}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['inventoryCatalogItem']['item']['spCode']}      ${itemEncId1}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['quantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['freeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['totalQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['amount']}      ${amount}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['discountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['taxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['taxAmount']}      ${taxAmount}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['netTotal']}      ${netTotal}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['discountPercentage']}      ${discountPercentage}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['hsnCode']}      ${hsnCode}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['expiryDate']}      ${expiryDate}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['mrp']}      ${mrp}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['batchNo']}      ${batchNo}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['purchaseUid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['unitCode']}      ${iu_id}


    ${resp}=    Get Purchase Filter
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}


JD-TC-GetPurchaseByFilter-3
    [Documentation]  Get Purchase Filter - location

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   location-eq=${locId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-4
    [Documentation]  Get Purchase Filter - locationName

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   locationName-eq=${place}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-5
    [Documentation]  Get Purchase Filter - storeEncId

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   storeEncId-eq=${encid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-6
    [Documentation]  Get Purchase Filter - storeName

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   storeName-eq=${SName}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-7
    [Documentation]  Get Purchase Filter - uid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   uid-eq=${purchaseId}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

# JD-TC-GetPurchaseByFilter-8

#     [Documentation]  Get Purchase Filter - purchaseReferenceNo

#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Get Purchase Filter   purchaseReferenceNo-eq=${purchaseReferenceNo}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}     200
#     Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
#     Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
#     Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
#     Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
#     Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
#     Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
#     Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
#     Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
#     Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
#     Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
#     Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
#     Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
#     Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
#     Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
#     Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
#     Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
#     Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}



JD-TC-GetPurchaseByFilter-11
    [Documentation]  Get Purchase Filter - invoicereferenceNo

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   invoiceReferenceNo-eq=${invoiceReferenceNo}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-12
    [Documentation]  Get Purchase Filter - invoiceDate

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   invoiceDate-eq=${invoiceDate}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}

JD-TC-GetPurchaseByFilter-13
    [Documentation]  Get Purchase Filter - purchaseStatus

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   purchaseStatus-eq=${PurchaseStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()[0]['store']['name']}      ${SName}
    Should Be Equal As Strings      ${resp.json()[0]['store']['encId']}      ${store_id}
    Should Be Equal As Strings      ${resp.json()[0]['inventoryCatalog']['encId']}      ${encid}
    Should Be Equal As Strings      ${resp.json()[0]['uid']}      ${purchaseId}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceReferenceNo']}      ${invoiceReferenceNo}
    Should Be Equal As Strings      ${resp.json()[0]['invoiceDate']}      ${invoiceDate}
    Should Be Equal As Strings      ${resp.json()[0]['purchaseNote']}      ${purchaseNote}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['vendorName']}      ${vender_name}
    Should Be Equal As Strings      ${resp.json()[0]['vendor']['encId']}      ${vendorId}
    Should Be Equal As Strings      ${resp.json()[0]['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalFreeQuantity']}      ${freeQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['netQuantity']}      ${totalQuantity}
    Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}      ${totalAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalDiscountAmount']}      ${totalDiscountAmount}
    Should Be Equal As Strings      ${resp.json()[0]['totalTaxableAmount']}      ${totaltaxableamount}
    Should Be Equal As Strings      ${resp.json()[0]['totalCgst']}      ${totalcgst}
    Should Be Equal As Strings      ${resp.json()[0]['totalSgst']}      ${totalSgst}


JD-TC-GetPurchaseByFilter-UH1
    [Documentation]  Get Purchase Filter - without login

    ${resp}=    Get Purchase Filter 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}


JD-TC-GetPurchaseByFilter-UH3
    [Documentation]  Get Purchase Filter - location invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   location-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []   

JD-TC-GetPurchaseByFilter-UH4
    [Documentation]  Get Purchase Filter - locationName invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   locationName-eq=abcd
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH5
    [Documentation]  Get Purchase Filter - storeEncId invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   storeEncId-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH6
    [Documentation]  Get Purchase Filter - storeName invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   storeName-eq=abcd
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH7
    [Documentation]  Get Purchase Filter - uid is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   uid-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH8
    [Documentation]  Get Purchase Filter - purchaseReferenceNo invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   purchaseReferenceNo-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH11
    [Documentation]  Get Purchase Filter - invoicereferenceNo invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   invoiceReferenceNo-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH12
    [Documentation]  Get Purchase Filter - invoiceDate invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=999   max=9999

    ${resp}=    Get Purchase Filter   invoiceDate-eq=${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []

JD-TC-GetPurchaseByFilter-UH13
    [Documentation]  Get Purchase Filter - purchaseStatus is another

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Purchase Filter   purchaseStatus-eq=${PurchaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()}          []