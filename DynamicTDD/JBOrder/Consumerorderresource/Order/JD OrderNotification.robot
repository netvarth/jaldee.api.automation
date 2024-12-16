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
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${minSaleQuantity}  1
${maxSaleQuantity}   50
${self}                0
${test_mail}           test@jaldee.com
${email_id1}            aparna.test@jaldee.com
${email_id2}            hisham.test@jaldee.com
${email_id3}            raigan.test@jaldee.com
${email_id4}            anu.test@jaldee.com


*** Test Cases ***

JD-TC-Order Notification-1

    [Documentation]  Order confirm notification for online order

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME10}
    Set Suite Variable    ${accountId} 

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pro_id}  ${decrypted_data['id']}

    ${fname}=  FakerLibrary.name
    ${resp}=  Update Service Provider With Emailid   ${pro_id}   ${fname}   ${fname}   ${Genderlist[0]}  ${EMPTY}  ${email_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${checkin_emails}=  Create List   ${email_id1}
    # ${push_msg_nos}=  Create Dictionary   number=${HLPUSERNAME10}   countryCode=${countryCodes[1]}
    # ${push_msg_nos}=  Create List   ${push_msg_nos}

    # ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[4]}  ${EventType[0]}  ${EMPTY_List}  ${checkin_emails}  ${push_msg_nos}  ${self}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Suite Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+400187748
    Set Suite Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id1}

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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id2}    ${primaryMobileNo}     ${accountId}
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


    ${postcode}=  FakerLibrary.postcode
    ${phone}=  Create Dictionary    number=${primaryMobileNo}   countryCode=91
    ${homeDeliveryAddress}=  Create Dictionary    firstName=${firstName}  lastName=${lastName}  email=${email_id}   address=${Name}  city=${firstName}  postalCode=${postcode}   phone=${phone}

    ${resp}=    CheckOut Cart Items   ${cart_uid}    homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${orderUid}    ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=    Get invoice Using order uid   ${accountId}   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${invoiceUid}    ${resp.json()[0]['uid']}


    ${resp}=  Make Prepayment From Consumerside     ${invoiceUid}    ${Total}      ${purpose[0]}    ${accountId}   ${finance_payment_modes[5]}   ${boolean[0]}  ${boolean[1]}   ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Order Notification-2

    [Documentation]  Order confirm notification for walkin order

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}
# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME16}
    Set Test Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Test Variable  ${address}
    Set Test Variable  ${postcode}
    Set Test Variable  ${city}

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1} 

    ${Name}=    FakerLibrary.first name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}  onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr False ------------------------------------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_Cata_Encid}  ${resp.json()}
# --------------------------------------------------------------------------------------------------------------
# ----------------------------------------  Create Item ---------------------------------------------------

    ${displayName}=     FakerLibrary.name
    ${displayName1}=     FakerLibrary.name
    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Create Item Inventory  ${displayName1}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId2}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}
# -------------------------------------------------------------------------------------------------------------------
# -------------------------------- Create SalesOrder Catalog Item-invMgmt False -----------------------------------

    ${price}=    Random Int  min=2   max=40
    ${invCatItem}=     Create Dictionary       encId=${itemEncId2}
    ${Item_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}   


    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}     ${Item_details}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    Set Test Variable  ${SO_itemEncIds2}  ${resp.json()[1]}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Test Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id3}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}
    Set Test Variable  ${SO_Cata_Encid_List}

    ${store}=  Create Dictionary   encId=${store_id}  
    Set Test Variable  ${store}

    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}    store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${SO_Uid}  ${resp.json()}

# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

*** Comments ***
JD-TC-Order Notification-3

    [Documentation]  Order cancellation notification for online order

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
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
    ${TypeName1}=    FakerLibrary.name
    Set Test Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Test Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME11}
    Set Test Variable    ${accountId} 

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}

    ${fname}=  FakerLibrary.name
    ${resp}=  Update Service Provider With Emailid   ${pro_id}   ${fname}   ${fname}   ${Genderlist[0]}  ${EMPTY}  ${email_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${checkin_emails}=  Create List   ${email_id1}
    # ${push_msg_nos}=  Create Dictionary   number=${HLPUSERNAME10}   countryCode=${countryCodes[1]}
    # ${push_msg_nos}=  Create List   ${push_msg_nos}

    # ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[4]}  ${EventType[0]}  ${EMPTY_List}  ${checkin_emails}  ${push_msg_nos}  ${self}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+400187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id1}

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


    ${displayName1}=     FakerLibrary.name
    Set Test Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId2}  ${resp.json()}

    ${displayName2}=     FakerLibrary.name
    Set Test Variable              ${displayName2} 
    ${resp}=    Create Item Inventory  ${displayName2}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId3}  ${resp.json()}


    ${price1}=    Random Int  min=70  max=90
    ${price1}=                    Convert To Number  ${price1}  1
    Set Test Variable    ${price1}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}    minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
    ${price2}=    Random Int  min=50   max=60
    ${price2}=                    Convert To Number  ${price2}  1
    Set Test Variable    ${price2}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}


# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Test Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
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
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}


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
    Set Test Variable    ${quantity} 
    ${item1}=  Evaluate  ${price}*${quantity}
    Set Test Variable    ${item1} 
    ${item2}=  Evaluate  ${price1}*${quantity}
    Set Test Variable    ${item2} 
    ${item3}=  Evaluate  ${price2}*${quantity}
    Set Test Variable    ${item3} 
    ${Total}=  Evaluate  ${item1}+${item2}+${item3}
    Set Test Variable    ${Total} 

    ${catalogItem}=  Create Dictionary    encId=${SOC_itemEncIds1}
    ${catalogItem1}=  Create Dictionary    encId=${SOC_itemEncIds2}
    ${catalogItem2}=  Create Dictionary    encId=${SOC_itemEncIds3}
    ${catalogItems}=  Create Dictionary    catalogItem=${catalogItem}  quantity=${quantity}
    ${catalogItems1}=  Create Dictionary    catalogItem=${catalogItem1}  quantity=${quantity}
    ${catalogItems2}=  Create Dictionary    catalogItem=${catalogItem2}  quantity=${quantity}

    ${resp}=  Create Cart From Consumerside      ${store_id}    ${cid1}      ${deliveryType[0]}    ${catalogItems}   ${catalogItems1}   ${catalogItems2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${cart_uid}    ${resp.json()['uid']}


    ${resp}=    Get ConsumerCart By Uid   ${cart_uid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                                              ${cid1}
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

    ${resp}=    CheckOut Cart Items   ${cart_uid}    homeDeliveryAddress=${homeDeliveryAddress}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${orderUid}    ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=    Get invoice Using order uid   ${accountId}   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${invoiceUid}    ${resp.json()[0]['uid']}

    sleep  02s

    ${resp}=  Make Prepayment From Consumerside     ${invoiceUid}    ${Total}      ${purpose[0]}    ${accountId}   ${finance_payment_modes[5]}   ${boolean[0]}  ${boolean[1]}   ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s

    ${resp}=    GetOrder using uid   ${orderUid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Order Notification-4

    [Documentation]  Order cancel notification for walkin order

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}
# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME12}
    Set Test Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    Set Test Variable  ${address}
    Set Test Variable  ${postcode}
    Set Test Variable  ${city}

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY1} 

    ${Name}=    FakerLibrary.first name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}  onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr False ------------------------------------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_Cata_Encid}  ${resp.json()}
# --------------------------------------------------------------------------------------------------------------
# ----------------------------------------  Create Item ---------------------------------------------------

    ${displayName}=     FakerLibrary.name
    ${displayName1}=     FakerLibrary.name
    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Create Item Inventory  ${displayName1}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId2}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}
# -------------------------------------------------------------------------------------------------------------------
# -------------------------------- Create SalesOrder Catalog Item-invMgmt False -----------------------------------

    ${price}=    Random Int  min=2   max=40
    ${invCatItem}=     Create Dictionary       encId=${itemEncId2}
    ${Item_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}   


    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}     ${Item_details}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    Set Test Variable  ${SO_itemEncIds2}  ${resp.json()[1]}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Test Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Test Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Test Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
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

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}
    Set Test Variable  ${SO_Cata_Encid_List}

    ${store}=  Create Dictionary   encId=${store_id}  
    Set Test Variable  ${store}

    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}    store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${SO_Uid}  ${resp.json()}

# --------------------------------------------- Update SalesOrder Status --------------------------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


 


