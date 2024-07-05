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

JD-TC-Get Order Filter-1

    [Documentation]  Get order filter using account id and storeencid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME22}
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

    ${Name}=    FakerLibrary.last name
    Set Suite Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+400187748
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
    Set Suite Variable    ${quantity} 
    ${item1}=  Evaluate  ${price}*${quantity}
    Set Suite Variable    ${item1} 
    ${item2}=  Evaluate  ${price1}*${quantity}
    Set Suite Variable    ${item2} 
    ${item3}=  Evaluate  ${price2}*${quantity}
    Set Suite Variable    ${item3} 
    ${Total}=  Evaluate  ${item1}+${item2}+${item3}
    Set Suite Variable    ${Total} 

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

    ${resp}=    CheckOut Cart Items   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${orderUid}    ${resp.json()}

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${orderType}    ${resp.json()['orderType']}
    Set Suite Variable    ${orderStatus}    ${resp.json()['orderStatus']}
    Set Suite Variable    ${deliveryType}    ${resp.json()['deliveryType']}
    Set Suite Variable    ${deliveryStatus}    ${resp.json()['deliveryStatus']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1} 
    ${resp}=    Get Order- Filter   providerConsumerId-eq=${cid}   soCatalogEncId-eq=${soc_id1}   accountId-eq=${accountId}   storeEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}


JD-TC-Get Order Filter-2
    [Documentation]  Get order filter using provider consumer id

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   providerConsumerId-eq=${cid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}

JD-TC-Get Order Filter-3
    [Documentation]  Get order filter using sorderCatalogEncId

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   soCatalogEncId-eq=${soc_id1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}


JD-TC-Get Order Filter-4
    [Documentation]  Get order filter using ordertype
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   orderType-eq=${orderType} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}


JD-TC-Get Order Filter-5
    [Documentation]  Get order filter using orderStatus
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   orderStatus-eq=${orderStatus} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}


JD-TC-Get Order Filter-6
    [Documentation]  Get order filter using deliveryType
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   deliveryType-eq=${deliveryType} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}


JD-TC-Get Order Filter-7
    [Documentation]  Get order filter using createdDate
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get Order- Filter   createdDate-eq=${DAY1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                                               ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                                            ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['id']}                                                              ${Stidd}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                                              ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['encId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['name']}                                                          ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog'][0]['invMgmt']}                                                       ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['id']}                                                  ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumer']['name']}                                                ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['id']}                                                          ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['orderFor']['name']}                                                        ${firstName} ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['orderType']}                                                            ${orderType}
    Should Be Equal As Strings    ${resp.json()[0]['orderStatus']}                                                            ${orderStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryType']}                                                            ${deliveryType}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryStatus']}                                                            ${deliveryStatus}
    Should Be Equal As Strings    ${resp.json()[0]['deliveryDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['createdDate']}                                                               ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['phone']['number']}                                          ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()[0]['contactInfo']['email']}                                                     ${email_id}
    Should Be Equal As Strings    ${resp.json()[0]['itemCount']}                                                                3
    Should Be Equal As Strings    ${resp.json()[0]['netTotal']}                                                                ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netTotalWithTax']}                                                         ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['netRate']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['amountDue']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['prePaymentAmount']}                                                                 ${Total}
    Should Be Equal As Strings    ${resp.json()[0]['order']['uid']}                                                            ${orderUid}
    Should Be Equal As Strings    ${resp.json()[0]['catEncIds'][0]}                                                            ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['catNames']['name']}                                                        ${Name}
