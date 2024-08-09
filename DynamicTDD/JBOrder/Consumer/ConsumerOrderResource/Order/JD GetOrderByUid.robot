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

*** Test Cases ***

JD-TC-Get Order By UID-1

    [Documentation]  Get Order by uid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME21}
    Set Suite Variable    ${accountId} 


    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}


    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Suite Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id1}    ${resp.json()}

    ${displayName}=     FakerLibrary.name
    Set Suite Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}


    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Suite Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


    ${displayName1}=     FakerLibrary.name
    Set Suite Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}


    ${displayName2}=     FakerLibrary.name
    Set Suite Variable              ${displayName2} 
    ${resp}=    Create Item Inventory  ${displayName2}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId3}  ${resp.json()}


    ${price1}=    Random Int  min=70  max=90
    ${price1}=                    Convert To Number  ${price1}  1
    Set Suite Variable    ${price1}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}    minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
    ${price2}=    Random Int  min=50   max=60
    ${price2}=                    Convert To Number  ${price2}  1
    Set Suite Variable    ${price2}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}


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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get Provider Catalog Item Filter    sorderCatalogEncId-eq=${soc_id1}  accountId-eq=${accountId}  storeEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    3
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds1}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId2}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId2}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName1}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price1}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds2}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds3}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId3}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId3}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName2}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price2}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds3}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}

        END
    END

    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${item1}=  Evaluate  ${price}*${quantity}
    ${item2}=  Evaluate  ${price1}*${quantity}
    ${item3}=  Evaluate  ${price2}*${quantity}
    ${Total}=  Evaluate  ${item1}+${item2}+${item3}

    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}
    ${catalogItem1}=  Create Dictionary    encId=${SOC_itemEncIds2}
    ${catalogItem2}=  Create Dictionary    encId=${SOC_itemEncIds3}
    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}
    ${catalogItems1}=  Create Dictionary    catalogItem=${catalogItem1}  quantity=${quantity}
    ${catalogItems2}=  Create Dictionary    catalogItem=${catalogItem2}  quantity=${quantity}

    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}   ${catalogItems1}   ${catalogItems2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${cart_uid}    ${resp.json()['uid']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1} 
    ${resp}=    Get ConsumerCart By Uid   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                              ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                            ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()['store']['name']}                                                       ${Name} 
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['uid']}                                                                 ${cart_uid}
    Should Be Equal As Strings    ${resp.json()['deliveryType']}                                                        ${deliveryType[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                                            ${Total}
    Should Be Equal As Strings    ${resp.json()['locationId']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                                             ${Total}


    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid}   homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${orderUid}    ${resp.json()}

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
    # Should Be Equal As Strings    ${resp.json()['status']}                                                                 ${billStatus[0]}
    Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
    # Should Be Equal As Strings    ${resp.json()['orderIncluded']}                                                           ${bool[1]}
    # Should Be Equal As Strings    ${resp.json()['viewStatus']}                                                               ${billViewStatus[0]}
    # Should Be Equal As Strings    ${resp.json()['invoiceDate']}                                                               ${DAY1}
    # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${Total}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalogItem']['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['encId']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['name']}                                         ${displayName}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['encId']}                                                       ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['orderQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['dueQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['itemAmount']}                                                        ${price}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netTotal']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netRate']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['spCode']}                                               ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['name']}                                                 ${displayName}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['catalogItem']['encId']}                                                        ${SOC_itemEncIds2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItem']['encId']}                                        ${itemEncId2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItem']['name']}                                         ${displayName1}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['encId']}                                                       ${SOC_itemEncIds2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['orderQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['dueQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['itemAmount']}                                                        ${price1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['netTotal']}                                                        ${item2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['netRate']}                                                        ${item2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['spCode']}                                               ${itemEncId2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['name']}                                                 ${displayName1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][1]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}

    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['catalogItem']['encId']}                                                        ${SOC_itemEncIds3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItem']['encId']}                                        ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItem']['name']}                                         ${displayName2}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['encId']}                                                       ${SOC_itemEncIds3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['orderQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['dueQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['itemAmount']}                                                        ${price2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['netTotal']}                                                        ${item3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['netRate']}                                                        ${item3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['spCode']}                                               ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['name']}                                                 ${displayName2}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][2]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}


JD-TC-Get Order By UID-2

    [Documentation]  one store contain two catalog ,two catalog contains same item then add two catalog items in cart

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    sleep  02s

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME150}
    Set Test Variable    ${accountId} 

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309167748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${Name1}=    FakerLibrary.last name
    Set Test Variable    ${Name1}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}


    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name1}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id2}    ${resp.json()}

    ${displayName}=     FakerLibrary.name
    Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id2}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}



# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
 

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}



    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${item1}=  Evaluate  ${price}*${quantity}
    ${Total}=  Evaluate  ${item1}+${item1}

    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}
    ${catalogItem1}=  Create Dictionary    encId=${SOC_itemEncIds2}
    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}
    ${catalogItems1}=  Create Dictionary    catalogItem=${catalogItem1}  quantity=${quantity}


    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}   ${catalogItems1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid}    ${resp.json()['uid']}

 

    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid}   homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${orderUid}    ${resp.json()}

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['catalog'][1]['encId']}                                                        ${soc_id2}
    Should Be Equal As Strings    ${resp.json()['catalog'][1]['name']}                                                          ${Name1}
    Should Be Equal As Strings    ${resp.json()['catalog'][1]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
    # Should Be Equal As Strings    ${resp.json()['status']}                                                                 ${billStatus[0]}
    Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
    # Should Be Equal As Strings    ${resp.json()['orderIncluded']}                                                           ${bool[1]}
    # Should Be Equal As Strings    ${resp.json()['viewStatus']}                                                               ${billViewStatus[0]}
    # Should Be Equal As Strings    ${resp.json()['invoiceDate']}                                                               ${DAY1}
    # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${Total}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalogItem']['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['encId']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['name']}                                         ${displayName}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['encId']}                                                       ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['orderQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['dueQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['itemAmount']}                                                        ${price}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netTotal']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netRate']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['spCode']}                                               ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['name']}                                                 ${displayName}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}

JD-TC-Get Order By UID-3

    [Documentation]  taxable item added in cart and then checkout the order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


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

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    sleep  02s

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME151}
    Set Test Variable    ${accountId} 

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309207748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}

    ${displayName}=     FakerLibrary.name
    Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}


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

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${itemtax_id1}           ${resp.json()['id']}

    ${tax1}=     Create List  ${itemtax_id1}
    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}    TaxInclude=${boolean[1]}    taxes=${tax1}  minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}




# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
 

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}



    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${item1}=  Evaluate  ${price}*${quantity}
    ${taxtot}=  Evaluate  ${item1}*${taxPercentage} 
    ${taxtot}=  Evaluate  ${taxtot} / 100
    ${Total}=  Evaluate  ${item1}+${taxtot}
    ${Total}=  roundoff  ${Total}
    ${cgsttot}=     Evaluate   ${taxtot} / 2


    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}
    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}



    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid}    ${resp.json()['uid']}

 

    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid}   homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${orderUid}    ${resp.json()}

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                                                ${item1}
    Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['gst']}                                                                 ${taxtot}
    Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                                           ${cgsttot}
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                                               ${cgsttot}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                                               ${taxtot}
    # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${Total}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalogItem']['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['encId']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['name']}                                         ${displayName}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['cgst']}                                                       ${cgsttot}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['sgst']}                                                       ${cgsttot}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['orderQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['dueQuantity']}                                                       ${quantity}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['itemAmount']}                                                        ${price}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netTotal']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netRate']}                                                        ${Total}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['spCode']}                                               ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['name']}                                                 ${displayName}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}

JD-TC-Get Order By UID-4

    [Documentation]  add one item to cart then remove that item from cart then try to checkout order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    sleep  02s

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME152}
    Set Test Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309167748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}


    ${displayName}=     FakerLibrary.name
    Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}





# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
 

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}



    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity}=                    Convert To Number  ${quantity}  1
    ${item1}=  Evaluate  ${price}*${quantity}


    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}

    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}



    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid}    ${resp.json()['uid']}

    ${resp}=    Get ConsumerCart With Items By Uid   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${cartItemUid1}    ${resp.json()['items'][0]['uid']}                     


    ${resp}=    Remove Item From Cart   ${cartItemUid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   items 
    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid}   homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FIELD_REQUIRED}

JD-TC-Get Order By UID-5

    [Documentation]  add one item to cart then remove that item then add another item ,update that one.again update from cart then try to checkout order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    sleep  02s

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME153}
    Set Test Variable    ${accountId} 

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309167748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}


    ${displayName}=     FakerLibrary.name
    Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}





# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
 

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}



    ${quantity}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity}=                    Convert To Number  ${quantity}  1



    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}

    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}



    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid}    ${resp.json()['uid']}

    ${resp}=    Get ConsumerCart With Items By Uid   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cartItemUid1}    ${resp.json()['items'][0]['uid']}                     


    ${resp}=    Remove Item From Cart   ${cartItemUid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid}      ${deliveryType[0]}    ${catalogItems}  
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable    ${cart_uid}    ${resp.json()['uid']}

    ${resp}=    Get ConsumerCart With Items By Uid   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable    ${cartItemUid1}    ${resp.json()['items'][0]['uid']}  
#  uid=${cartItemUid1}    
    ${quantity1}=  FakerLibrary.Random Int  min=${minSaleQuantity}   max=${maxSaleQuantity}
    ${quantity1}=                    Convert To Number  ${quantity1}  1
    ${item1}=  Evaluate  ${price}*${quantity1}
    ${resp}=  Update Cart Items     ${cartUid}   ${SOC_itemEncIds1}    ${quantity1}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${FIELD_REQUIRED}=  format String   ${FIELD_REQUIRED}   items 
    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}
    ${resp}=    CheckOut Cart Items   ${cart_uid}   homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${orderUid}    ${resp.json()}

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                                        ${soc_id1}
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
    Should Be Equal As Strings    ${resp.json()['gst']}                                                                 0.0
    Should Be Equal As Strings    ${resp.json()['paymentStatus']}                                                            ${paymentStatus[0]}
    Should Be Equal As Strings    ${resp.json()['timezone']}                                                                Asia/Kolkata
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                                           0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                                               0.0
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                                               0.0
    # Should Be Equal As Strings    ${resp.json()['encId']}                                                                   ${orderUid}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()['prePaymentAmount']}                                                           ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['accountId']}                                                           ${accountId}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalog']['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['catalogItem']['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['encId']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItem']['name']}                                         ${displayName}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['cgst']}                                                       ${cgsttot}
    # Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['sgst']}                                                       ${cgsttot}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['orderQuantity']}                                                       ${quantity1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['status']}                                                        ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['dueQuantity']}                                                       ${quantity1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['itemAmount']}                                                        ${price}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netTotal']}                                                        ${item1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['netRate']}                                                            ${item1} 
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSourceEnum']}                                        ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['spCode']}                                               ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['name']}                                                 ${displayName}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isInventoryItem']}                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemGroups']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemSubGroups']}                                            []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['tax']}                                                      []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['composition']}                                               []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemUnits']}                                                []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['isBatchApplicable']}                                          ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['attachments']}                                              []
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['status']}                                                ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdDate']}                                              ${DAY1}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['createdBy']}                                                ${p1_id}
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['updatedBy']}                                                0
    Should Be Equal As Strings    ${resp.json()['itemDtoList'][0]['spItemDto']['itemPropertyType']}                                         ${itemPropertyType}