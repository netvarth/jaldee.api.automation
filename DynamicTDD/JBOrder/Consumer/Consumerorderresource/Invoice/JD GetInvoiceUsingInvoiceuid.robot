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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${minSaleQuantity}  1
${maxSaleQuantity}   50
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
${originFrom}       NONE

*** Test Cases ***

# JD-TC-Get Invoice Using InvoiceID-1

#     [Documentation]  Get Invoice Using InvoiceID

#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Account Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     IF  ${resp.json()['enableInventory']}==${bool[0]}
#         ${resp1}=  Enable Disable Inventory  ${toggle[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
#     END

#     IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
#         ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
#     END

#     ${resp}=  Get jp finance settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

    
#     IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
#         ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END

#     ${resp}=  Get jp finance settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

#     ${resp}=  Get Store Type By Filter     
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${TypeName}=    FakerLibrary.name
#     Set Suite Variable  ${TypeName}
# # -------------------------------- Create store type -----------------------------------
#     ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${St_Id}    ${resp.json()}
#     sleep  02s
#     ${TypeName1}=    FakerLibrary.name
#     Set Suite Variable  ${TypeName1}

#     ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${St_Id1}    ${resp.json()}
#     sleep  02s
#     ${TypeName2}=    FakerLibrary.name
#     Set Suite Variable  ${TypeName2}

#     ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${St_Id2}    ${resp.json()}

#     ${resp}=  Get Store Type By EncId   ${St_Id}    
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
#     Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
#     Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME24}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${accountId}=  get_acc_id  ${HLPUSERNAME24}
#     Set Suite Variable    ${accountId} 

#     ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
#     Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
#     Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId1}=  Create Sample Location
#         ${resp}=   Get Location ById  ${locId1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
#     ELSE
#         Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
#         Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
#     END

#     ${Name}=    FakerLibrary.last name
#     Set Suite Variable    ${Name}
#     ${PhoneNumber}=  Evaluate  ${PUSERNAME}+307187748
#     Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
#     ${email}=  Create List  ${email_id}

#     ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${store_id}  ${resp.json()}


#     ${resp}=    Get Store ByEncId   ${store_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable    ${Stidd}    ${resp.json()['id']}


#     ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable              ${soc_id1}    ${resp.json()}

#     ${displayName}=     FakerLibrary.name
#     Set Suite Variable              ${displayName} 

#     ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${itemEncId1}  ${resp.json()}

#     ${price}=    Random Int  min=2   max=40
#     ${price}=                    Convert To Number  ${price}  1
#     Set Suite Variable              ${price} 
#     ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


#     ${displayName1}=     FakerLibrary.name
#     Set Suite Variable  ${displayName1}
#     ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${itemEncId2}  ${resp.json()}

#     ${displayName2}=     FakerLibrary.name
#     Set Suite Variable              ${displayName2} 
#     ${resp}=    Create Item Inventory  ${displayName2}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${itemEncId3}  ${resp.json()}


#     ${price1}=    Random Int  min=70  max=90
#     ${price1}=                    Convert To Number  ${price1}  1
#     Set Suite Variable    ${price1}  
#     ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}    minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
#     ${price2}=    Random Int  min=50   max=60
#     ${price2}=                    Convert To Number  ${price2}  1
#     Set Suite Variable    ${price2}  
#     ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}


# # -------------------------------- Add a provider Consumer -----------------------------------

#     ${firstName}=  FakerLibrary.name
#     Set Suite Variable    ${firstName}
#     ${lastName}=  FakerLibrary.last_name
#     Set Suite Variable    ${lastName}
#     ${primaryMobileNo}    Generate random string    10    123456789
#     ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
#     Set Suite Variable    ${primaryMobileNo}
#     # ${email}=    FakerLibrary.Email
#     # Set Suite Variable    ${email}

#     ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable  ${token}  ${resp.json()['token']}

#     ${resp}=    Customer Logout 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200    
   
#     ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


#     ${resp}=    Get Provider Catalog Item Filter    sorderCatalogEncId-eq=${soc_id1}  accountId-eq=${accountId}  storeEncId-eq=${store_id}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${len}=  Get Length  ${resp.json()}
#     Should Be Equal As Strings    ${len}    3
 

#     FOR  ${i}  IN RANGE   ${len}

#         IF  '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds1}'  
#             Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price}
#             Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


#         ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds2}'      
#             Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId2}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId2}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds2}
#             Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


#         ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds3}'      
#             Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
#             Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId3}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId3}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName2}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price2}
#             Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds3}
#             Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
#             Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}

#         END
#     END

#     ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
#     ${quantity}=                    Convert To Number  ${quantity}  1
#     ${item1}=  Evaluate  ${price}*${quantity}
#     ${item2}=  Evaluate  ${price1}*${quantity}
#     ${item3}=  Evaluate  ${price2}*${quantity}
#     ${Total}=  Evaluate  ${item1}+${item2}+${item3}

#     ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}
#     ${catalogItem1}=  Create Dictionary    encId=${SOC_itemEncIds2}
#     ${catalogItem2}=  Create Dictionary    encId=${SOC_itemEncIds3}
#     ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}
#     ${catalogItems1}=  Create Dictionary    catalogItem=${catalogItem1}  quantity=${quantity}
#     ${catalogItems2}=  Create Dictionary    catalogItem=${catalogItem2}  quantity=${quantity}

#     ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}   ${catalogItems1}   ${catalogItems2}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${cart_uid}    ${resp.json()['uid']}


#     ${resp}=    Get ConsumerCart By Uid   ${cart_uid} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                              ${cid}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                            ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['store']['encId']}                                                      ${store_id}
#     Should Be Equal As Strings    ${resp.json()['store']['name']}                                                       ${Name} 
#     Should Be Equal As Strings    ${resp.json()['accountId']}                                                           ${accountId}
#     Should Be Equal As Strings    ${resp.json()['uid']}                                                                 ${cart_uid}
#     Should Be Equal As Strings    ${resp.json()['deliveryType']}                                                        ${deliveryType[0]}
#     Should Be Equal As Strings    ${resp.json()['netTotal']}                                                            ${Total}
#     Should Be Equal As Strings    ${resp.json()['locationId']}                                                            ${locId1}
#     Should Be Equal As Strings    ${resp.json()['netRate']}                                                             ${Total}


#     ${postcode}=  FakerLibrary.postcode
#     ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
#     ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
#     ${resp}=    CheckOut Cart Items   ${cart_uid}    homeDeliveryAddress=${homeDeliveryAddress}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${orderUid}    ${resp.json()}
#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${resp}=    Get invoice Using order uid   ${accountId}   ${orderUid} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Suite Variable    ${invoiceUid}    ${resp.json()[0]['uid']}


#     ${resp}=    Get invoice Using Invoice uid   ${accountId}   ${invoiceUid} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
#     Should Be Equal As Strings    ${resp.json()['order']['uid']}                                                            ${orderUid}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
#     Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${Total}
#     Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${Total}
#     Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${Total}
#     Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${Total}
#     Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
#     Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
#     Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid}
#     Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['status']}                                                                 ${billStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
#     Should Be Equal As Strings    ${resp.json()['orderIncluded']}                                                           ${bool[1]}
#     Should Be Equal As Strings    ${resp.json()['viewStatus']}                                                               ${billViewStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['invoiceDate']}                                                               ${DAY1}
#     # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
#     Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
#     Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
#     Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
#     Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${Total}


# JD-TC-Get Invoice Using InvoiceID-2

#     [Documentation]  In the sales order catalog where inventory manager is on , only courier delivery is disable and store pickup is enabled. Then, try to add an item to the cart using Courier Service.then get that invoice using uid


#     ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Account Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     IF  ${resp.json()['enableInventory']}==${bool[0]}
#         ${resp1}=  Enable Disable Inventory  ${toggle[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END
#     IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
#         ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200

#         ${resp}=  Get Account Settings
#         Log  ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
#     END


#     ${resp}=  Get Store Type By Filter     
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${TypeName}=    FakerLibrary.name
#     Set Test Variable  ${TypeName}
# # -------------------------------- Create store type -----------------------------------
#     ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${St_Id}    ${resp.json()}
#     sleep  02s


#     ${resp}=  Get Store Type By EncId   ${St_Id}    
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
#     Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
#     Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${accountId}=  get_acc_id  ${PUSERNAME1}
#     Set Test Variable    ${accountId} 

#     ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
#     Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
#     Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId1}=  Create Sample Location
#         ${resp}=   Get Location ById  ${locId1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
#     ELSE
#         Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
#         Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
#     END

#     ${Name}=    FakerLibrary.last name
#     Set Test Variable    ${Name}
#     ${PhoneNumber}=  Evaluate  ${PUSERNAME}+105187748
#     Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
#     ${email}=  Create List  ${email_id}

#     ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${store_id}  ${resp.json()}

#     ${resp}=    Get Store ByEncId   ${store_id}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable    ${Stidd}    ${resp.json()['id']}



#     ${displayName}=     FakerLibrary.name
#     Set Test Variable              ${displayName} 

#     ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${itemEncId1}  ${resp.json()}

#     ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
#     ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

#     ${resp}=   Create Inventory Catalog Item  ${inv_cat_encid1}   ${itemEncId1}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}



#     ${price}=    Random Int  min=2   max=40
#     ${price}=                    Convert To Number  ${price}  1
#     Set Test Variable              ${price} 

#     # ... Create itemUnits ....

#     ${unitName}=                    FakerLibrary.name
#     ${convertionQty}=               Random Int  min=1  max=20
#     Set Test Variable              ${unitName}
#     Set Test Variable              ${convertionQty}

#     ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}    200
#     Set Test Variable   ${iu_id}   ${resp.json()}

#     # ............... Create Vendor ...............

#     ${resp}=  Populate Url For Vendor   ${account_id}   
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=  CreateVendorCategory  ${Name}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${category_id1}   ${resp.json()}

#     ${resp}=  Get by encId  ${category_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['name']}          ${Name}
#     Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id}
#     Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

#     ${vender_name}=   FakerLibrary.firstname
#     ${contactPersonName}=   FakerLibrary.lastname
#     ${vendorId}=   FakerLibrary.word
#     ${PO_Number}    Generate random string    5    123456789
#     ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
#     ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
#     Set Test Variable  ${email}  ${vender_name}.${test_mail}
#     ${address}=  FakerLibrary.city
#     Set Test Variable  ${address}
#     ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
#     ${branch}=   db.get_place
#     ${ifsc_code}=   db.Generate_ifsc_code
#     ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
#     ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
#     Set Test Variable      ${vender_name}

#     ${state}=    Evaluate     "${state}".title()
#     ${state}=    String.RemoveString  ${state}    ${SPACE}
#     Set Test Variable    ${state}
#     Set Test Variable    ${district}
#     Set Test Variable    ${pin}
#     ${vendor_phno}=   Create List  ${vendor_phno}
#     Set Test Variable    ${vendor_phno}
    
#     ${email}=   Create List  ${email}
#     Set Test Variable    ${email}

#     ${bankIfsc}    Random Number 	digits=5 
#     ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
#     Log  ${bankIfsc}
#     Set Test Variable  ${bankIfsc}  55555${bankIfsc} 

#     ${bankName}     FakerLibrary.name
#     Set Test Variable    ${bankName}

#     ${upiId}     FakerLibrary.name
#     Set Test Variable  ${upiId}

#     ${pan}    Random Number 	digits=5 
#     ${pan}=    Evaluate    f'{${pan}:0>5d}'
#     Log  ${pan}
#     Set Test Variable  ${pan}  55555${pan}

#     ${branchName}=    FakerLibrary.name
#     Set Test Variable  ${branchName}
#     ${gstin}    Random Number 	digits=5 
#     ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
#     Log  ${gstin}
#     Set Test Variable  ${gstin}  55555${gstin}

#     ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
#     ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
#     ${bankInfo}=    Create List         ${bankInfo}                
#     ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable      ${vendorId}     ${resp.json()['encId']}


#     # ............... Create Purchase...............
#     ${expiryDate}=  db.add_timezone_date  ${tz}  50
#     Set Test Variable          ${expiryDate}

#     ${mrp}=                     Random Int              min=1  max=9999
#     ${mrp}=                     Convert To Number  ${mrp}  1
#     ${batchNo}=                 Random Int              min=1  max=9999
#     ${invoiceReferenceNo}=      Random Int              min=1  max=999
#     ${purchaseNote}=            FakerLibrary.Sentence
#     ${freeQuantity}=                Random Int  min=0  max=10
#     ${freeQuantity}=                Convert To Number  ${freeQuantity}  1
#     ${DAY1}=  db.get_date_by_timezone  ${tz}

#     ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${Inv_Cata_Item_Encid1}  200  ${freeQuantity}    ${price}  0  0  0  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}   
#     Set Test Variable              ${purchaseItemDtoList1}

#     ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${DAY1}  ${vendorId}  ${inv_cat_encid1}  ${purchaseNote}  1  ${purchaseItemDtoList1}  
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}   200
#     Set Test Variable              ${purchaseId}           ${resp.json()}


#     ${resp}=    Get Purchase By Uid  ${purchaseId} 
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}                 200
#     Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}

#     ${resp}=    Update Purchase Status  ${PurchaseStatus[1]}  ${purchaseId} 
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}     200

#     ${resp}=    Get Purchase By Uid  ${purchaseId} 
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}                 200
#     Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[1]}

#     ${resp}=    Update Purchase Status  ${PurchaseStatus[2]}  ${purchaseId} 
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}     200

#     ${resp}=    Get Purchase By Uid  ${purchaseId} 
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}                 200
#     Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[2]}

#     # ............... sales order catalog and item adding...............
#     ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}   ${Name}  ${boolean[0]}  ${inv_cat_encid}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable              ${soc_id1}    ${resp.json()}

#     ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${soc_id1}    ${boolean[1]}     ${Inv_Cata_Item_Encid1}     ${price}    ${boolean[1]}   minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200


# # -------------------------------- Add a provider Consumer -----------------------------------

#     ${firstName}=  FakerLibrary.name
#     Set Test Variable    ${firstName}
#     ${lastName}=  FakerLibrary.last_name
#     Set Test Variable    ${lastName}
#     ${primaryMobileNo}    Generate random string    10    123458679
#     ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
#     Set Test Variable    ${primaryMobileNo}
#     # ${email}=    FakerLibrary.Email
#     # Set Test Variable    ${email}

#     ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${token2}  ${resp.json()['token']}

#     ${resp}=    Customer Logout 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200    
   
#     ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token2} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable    ${cid2}    ${resp.json()['providerConsumer']}

#    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
#     ${quantity}=                    Convert To Number  ${quantity}  1
#     ${item1}=  Evaluate  ${price}*${quantity}


#     ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}

#     ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}

#     ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid2}      ${deliveryType[0]}    ${catalogItems}   
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${cart_uid1}    ${resp.json()['uid']}


#     ${resp}=    Get ConsumerCart By Uid   ${cartUid1} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                              ${cid2}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                            ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['store']['encId']}                                                      ${store_id}
#     Should Be Equal As Strings    ${resp.json()['store']['name']}                                                       ${Name} 
#     Should Be Equal As Strings    ${resp.json()['accountId']}                                                           ${accountId}
#     Should Be Equal As Strings    ${resp.json()['uid']}                                                                 ${cartUid1}
#     Should Be Equal As Strings    ${resp.json()['deliveryType']}                                                        ${deliveryType[0]}
#     Should Be Equal As Strings    ${resp.json()['netTotal']}                                                            ${item1}
#     Should Be Equal As Strings    ${resp.json()['locationId']}                                                            ${locId1}
#     Should Be Equal As Strings    ${resp.json()['netRate']}                                                             ${item1}


#     ${postcode}=  FakerLibrary.postcode
#     ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
#     ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
#     ${resp}=    CheckOut Cart Items   ${cart_uid1}    homeDeliveryAddress=${homeDeliveryAddress}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${orderUid}    ${resp.json()}

#     ${resp}=    Get invoice Using order uid   ${accountId}   ${orderUid} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${invoiceUid}    ${resp.json()[0]['uid']}


#     ${resp}=    Get invoice Using Invoice uid   ${accountId}   ${invoiceUid} 
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
#     Should Be Equal As Strings    ${resp.json()['order']['uid']}                                                            ${orderUid}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid2}
#     Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
#     Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
#     Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${item1}
#     Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${item1}
#     Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${item1}
#     Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${item1}
#     Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
#     Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
#     Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid2}
#     Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
#     Should Be Equal As Strings    ${resp.json()['status']}                                                                 ${billStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
#     Should Be Equal As Strings    ${resp.json()['orderIncluded']}                                                           ${bool[1]}
#     Should Be Equal As Strings    ${resp.json()['viewStatus']}                                                               ${billViewStatus[0]}
#     Should Be Equal As Strings    ${resp.json()['invoiceDate']}                                                               ${DAY1}
#     # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
#     Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
#     Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
#     Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
#     Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${item1}


JD-TC-Get Invoice Using InvoiceID-3

    [Documentation]  In the sales order catalog where inventory manager is on , only courier delivery is disable and store pickup is enabled. Then, try to add an item to the cart using Courier Service.then get that invoice using uid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pid}          ${decrypted_data['id']}
    Set Test Variable      ${pdrname}      ${decrypted_data['userName']}

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

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id}   ${resp}

    ${resp}=   Get Location ById  ${loc_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    # .... Create Hsn .....

    ${hsnCode}=                 Random Int  min=1  max=999
    Set Test Variable          ${hsnCode}

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable      ${hsn_id}      ${resp.json()}

    # .... Create Jrx Item ......

    ${itemName}=        FakerLibrary.name
    ${description}=     FakerLibrary.sentence
    ${sku}=             FakerLibrary.name
    Set Test Variable  ${itemName}
    Set Test Variable  ${description}
    Set Test Variable  ${sku}

    ${hsn}=     Create Dictionary    hsnCode=${hsnCode}

    ${resp}=    Create Item Jrx   ${itemName}  description=${description}  sku=${sku}  hsnCode=${hsn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable     ${itemjrx}   ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
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
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${place}    ${resp.json()[0]['place']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        Set Test Variable  ${place}    ${resp.json()[0]['place']}
    END

    ${SName}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${SName}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Test Variable      ${SName}

    ${resp}=  Create Store   ${SName}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable            ${store_id}           ${resp.json()} 

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}


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
    Set Test Variable      ${vender_name}

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

    # .......... Create Inventory Catalog Item ..........

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ...... Create Category .......

    ${categoryName}=    FakerLibrary.name
    Set Test Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${categoryCode}     ${resp.json()}

    # ...... Create Type .........

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}

    ${resp}=  Create Item Type   ${TypeName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${typeCode}     ${resp.json()}

    # ..... Create manufacturer .....

    ${manufactureName}=    FakerLibrary.name
    Set Test Variable  ${manufactureName}

    ${resp}=  Create Item Manufacture   ${manufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${manufacturerCode}     ${resp.json()}

    # .... Cretate Group 01 ........

    ${groupName}=    FakerLibrary.name
    Set Test Variable      ${groupName}

    ${groupDesc}=    FakerLibrary.name
    Set Test Variable  ${groupDesc}

    ${groupCode}=   FakerLibrary.Sentence   nb_words=3
    Set Test Variable  ${groupCode}

    ${resp}=    Create Item group Provider  ${groupName}  ${groupCode}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${ig_id}   ${resp.json()}

    # .... Cretate Group 02 ........

    ${groupName2}=    FakerLibrary.name
    Set Test Variable      ${groupName2}

    ${groupDesc2}=    FakerLibrary.name
    Set Test Variable  ${groupDesc2}

    ${groupCode2}=   FakerLibrary.Sentence   nb_words=3
    Set Test Variable  ${groupCode2}

    ${resp}=    Create Item group Provider  ${groupName2}  ${groupCode2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${ig_id2}   ${resp.json()}

    ${itemGroups}=  Create List  ${ig_id}  ${ig_id2}

    # ..... Create Tax ......

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${taxPercentage}=           Convert To Number  ${taxPercentage}  1
    ${cgst}=     Evaluate   ${taxPercentage} / 2
    ${sgst}=     Evaluate   ${taxPercentage} / 2
    Set Test Variable      ${taxName}
    Set Test Variable      ${taxPercentage}
    Set Test Variable      ${cgst}
    Set Test Variable      ${sgst}

    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${itemtax_id}  ${resp.json()}

    ${tax}=     Create List  ${itemtax_id}

    # ....... Create composition ......

    ${compositionName}=     FakerLibrary.name
    Set Test Variable  ${compositionName}

    ${resp}=    Create Item Composition     ${compositionName} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${compositionCode}    ${resp.json()}

    ${composition}=     Create List  ${compositionCode}

    # ... Create itemUnits ....

    ${unitName}=                    FakerLibrary.name
    ${convertionQty}=               Random Int  min=1  max=20
    Set Test Variable              ${unitName}
    Set Test Variable              ${convertionQty}

    ${resp}=    Create Item Unit    ${unitName}  ${convertionQty}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable   ${iu_id}   ${resp.json()}

    ${itemUnits}=   Create List     ${iu_id}

    # .... Attachments ......

    ${resp}=            db.getType  ${jpgfile} 
    Log  ${resp}
    ${fileType}=                    Get From Dictionary       ${resp}    ${jpgfile} 
    Set Test Variable              ${fileType}
    ${caption}=                     Fakerlibrary.Sentence
    Set Test Variable              ${caption}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 
    Set Test Variable              ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  fileName=${jpgfile}  fileSize=${fileSize}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    ${attachments}=  Create List    ${attachments}
    Set Test Variable              ${attachments}

    ${nameit}=                        FakerLibrary.name
    ${shortDesc}=                   FakerLibrary.sentence
    ${internalDesc}=                FakerLibrary.sentence
    Set Test Variable              ${nameit}
    Set Test Variable              ${shortDesc}
    Set Test Variable              ${internalDesc}

    ${resp}=    Create Item Inventory  ${nameit}  shortDesc=${shortDesc}   internalDesc=${internalDesc}   itemCode=${itemjrx}   categoryCode=${categoryCode}  categoryCode2=${categoryCode}  typeCode=${typeCode}  typeCode2=${typeCode}  hsnCode=${hsnCode}  manufacturerCode=${manufacturerCode}  sku=${sku}  isBatchApplicable=${boolean[1]}  isInventoryItem=${bool[1]}  itemGroups=${itemGroups}  itemSubGroups=${itemGroups}  tax=${tax}  composition=${composition}  itemUnits=${itemUnits}  attachments=${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemEncId1}  ${resp.json()}

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
    Set Test Variable   ${ic_id}   ${resp.json()[0]}

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
    Set Test Variable              ${quantity}
    Set Test Variable              ${freeQuantity}
    Set Test Variable              ${amount}
    Set Test Variable              ${discountPercentage}
    Set Test Variable              ${fixedDiscount}
    Set Test Variable              ${inventoryCatalogItem}

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
    Set Test Variable              ${totalQuantity}
    Set Test Variable              ${netTotal}
    Set Test Variable              ${discountAmount}
    Set Test Variable              ${taxableAmount}
    Set Test Variable              ${cgstamount}
    Set Test Variable              ${sgstamount}
    Set Test Variable              ${taxAmount}
    Set Test Variable              ${netRate}

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


    ${expiryDate}=  db.add_timezone_date  ${tz}  50
    Set Test Variable          ${expiryDate}

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
    Set Test Variable          ${invoiceReferenceNo}
    Set Test Variable          ${purchaseNote}
    Set Test Variable          ${invoiceDate}
    Set Test Variable          ${totaltaxableamount}
    Set Test Variable          ${totalDiscountAmount}
    Set Test Variable          ${totalSgst}
    Set Test Variable          ${totalcgst}
    Set Test Variable          ${totaltaxable}
    Set Test Variable          ${totalAmount}
    Set Test Variable          ${roundOff}
    Set Test Variable          ${taxAmount}
    Set Test Variable          ${mrp}
    Set Test Variable          ${salesRate}
    Set Test Variable          ${batchNo}

    ${purchaseItemDtoList1}=        Create purchaseItemDtoList  ${ic_id}  ${quantity}  ${freeQuantity}    ${amount}  ${discountAmount}  ${discountPercentage}  500  ${expiryDate}  ${mrp}  ${batchNo}  ${iu_id}    
    Set Test Variable              ${purchaseItemDtoList1}

    ${resp}=    Create Purchase  ${store_id}  ${invoiceReferenceNo}  ${invoiceDate}  ${vendorId}  ${encid}  ${purchaseNote}  1  ${purchaseItemDtoList1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Test Variable              ${purchaseId}           ${resp.json()}

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
    # Should Be Equal As Strings      ${resp.json()['totalQuantity']}      ${quantity}
    Should Be Equal As Strings      ${resp.json()['totalFreeQuantity']}      ${freeQuantity}
    # Should Be Equal As Strings      ${resp.json()['netQuantity']}      ${totalQuantity}
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
    # Should Be Equal As Strings      ${resp.json()['purchaseItemDtoList'][0]['totalQuantity']}      ${totalQuantity}
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

    ${resp}=    Get Purchase By Uid  ${purchaseId} 
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200
    Should Be Equal As Strings      ${resp.json()['purchaseStatus']}    ${PurchaseStatus[0]}
    Set Test Variable              ${purchaseItemEncId}                ${resp.json()['purchaseItemDtoList'][0]['encId']}

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



    ${inv_cat_encid_List}=  Create List  ${encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid_List}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_order_encid}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 


    # Set Test Variable  ${SO_itemEncIds}  ${resp.json()[0]['encId']}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_id}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${sOrderCatalog}=   Create Dictionary    encId=${inv_order_encid}
    Set Test Variable      ${sOrderCatalog}

    ${Details1}=  Create Dictionary     purchaseItemEncId=${purchaseItemEncId}  sOrderCatalog=${sOrderCatalog}  salesRate=${salesRate}

    ${resp}=    Add Details To Catalog  ${purchaseId}  ${Details1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${inv_order_encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Get Inventoryitem      ${ic_id}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${batch_encid}  ${resp.json()[0]['uid']}

    ${resp}=    Get Stock Avaliability  ${ic_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=           FakerLibrary.name
    Set Test Variable      ${firstName}
    ${lastName}=            FakerLibrary.last_name
    Set Test Variable      ${lastName}
    ${primaryMobileNo}      Generate random string    10    123456789
    ${primaryMobileNo}      Convert To Integer  ${primaryMobileNo}
    Set Test Variable      ${primaryMobileNo}
    Set Test Variable       ${email_id}  ${lastName}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${item1}=  Evaluate  ${salesRate}*${quantity}


    ${catalogItem}=  Create Dictionary    encId=${SO_itemEncIds}

    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}

    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid1}    ${resp.json()['uid']}


    # ${resp}=    Get ConsumerCart By Uid   ${cartUid1} 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                              ${cid}
    # Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                            ${firstName} ${lastName}
    # Should Be Equal As Strings    ${resp.json()['store']['encId']}                                                      ${store_id}
    # Should Be Equal As Strings    ${resp.json()['store']['name']}                                                       ${Name} 
    # Should Be Equal As Strings    ${resp.json()['accountId']}                                                           ${accountId}
    # Should Be Equal As Strings    ${resp.json()['uid']}                                                                 ${cartUid1}
    # Should Be Equal As Strings    ${resp.json()['deliveryType']}                                                        ${deliveryType[0]}
    # Should Be Equal As Strings    ${resp.json()['netTotal']}                                                            ${item1}
    # Should Be Equal As Strings    ${resp.json()['locationId']}                                                            ${locId1}
    # Should Be Equal As Strings    ${resp.json()['netRate']}                                                             ${item1}


    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid1}    homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${orderUid}    ${resp.json()}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=    Get invoice Using order uid   ${accountId}   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${invoiceUid}    ${resp.json()[0]['uid']}


    ${resp}=    Get invoice Using Invoice uid   ${accountId}   ${invoiceUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['phone']['countryCode']}                                 +91
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['phone']['number']}                                      ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['whatsapp']['countryCode']}                                 91
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['whatsapp']['number']}                                  ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['telegram']['countryCode']}                                 91
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['telegram']['number']}                                   ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${inv_order_encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${item1}
    Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${item1}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${item1}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${item1}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['status']}                                                                 ${billStatus[0]}
    Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
    Should Be Equal As Strings    ${resp.json()['orderIncluded']}                                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['viewStatus']}                                                               ${billViewStatus[0]}
    Should Be Equal As Strings    ${resp.json()['invoiceDate']}                                                               ${DAY1}
    # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${item1}


