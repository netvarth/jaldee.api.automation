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

*** Test Cases ***

JD-TC-Apply SalesOrder discount-1

    [Documentation]   Create a sales Order with Valid Details and Genarate invoice then apply discount(calculationType is Percentage and discType is Predefine).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
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
# ---------------------    Create Store Type from sa side ----------------------------
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
# ------------------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME28}
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

# ---------------------    Create Store ----------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name} 

    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

# ------------------------------------------------------------------------------------

# ---------------------    Create SalesOrder Inventory Catalog-InvMgr False ----------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}
# ------------------------------------------------------------------------------------
# ---------------------    Create Item -----------------------------------------------

    ${displayName}=     FakerLibrary.name
    ${displayName1}=     FakerLibrary.name
    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Create Item Inventory  ${displayName1}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}
# ------------------------------------------------------------------------------------
# ---------------------    Create SalesOrder Catalog Item-invMgmt False --------------

    ${price}=    Random Int  min=2   max=40
    Set Suite Variable  ${price}
    ${invCatItem}=     Create Dictionary       encId=${itemEncId2}
    ${Item_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}   


    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}     ${Item_details}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    Set Suite Variable  ${SO_itemEncIds2}  ${resp.json()[1]}

# ---------------------    Add a provider Consumer -----------------------------------

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

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# ------------------------------------------------------------------------------------

# ---------------------    Provider take a Sales Order -------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}
    Set Suite Variable  ${SO_Cata_Encid_List}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1
    Set Suite Variable  ${netTotal}


    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}                                   ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}                                  ${store_id}

    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}

    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                ${firstName} ${lastName}

    Should Be Equal As Strings    ${resp.json()['orderType']}                                       ${bookingChannel[0]}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryType']}                                    ${deliveryType[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryStatus']}                                  ${deliveryStatus[0]}
    Should Be Equal As Strings    ${resp.json()['originFrom']}                                      ${originFrom[5]}

    Should Be Equal As Strings    ${resp.json()['orderNum']}                                        1
    Should Be Equal As Strings    ${resp.json()['orderRef']}                                        1
    Should Be Equal As Strings    ${resp.json()['deliveryDate']}                                    ${DAY1}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                  ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                            ${email_id}

    Should Be Equal As Strings    ${resp.json()['itemCount']}                                       1
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                        0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                   0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                               0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                             0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                         ${netTotal}
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0

    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
# ------------------------------------------------------------------------------------
# ---------------------    Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# ---------------------    Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# ---------------------    Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${netTotal}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0

# --------------------------------------------- Apply discount For SalesOrder --------

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[0]}  ${disctype[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}   

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1
    Set Suite Variable   ${discountValue1}

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${bal_Total}=  Evaluate  ${netTotal}*${discountprice}
    ${bal_Total}=  Convert To Number  ${bal_Total}   1
    ${bal_Total}=  Evaluate  ${bal_Total}/ 100

    ${discount_final_price}=  Evaluate  ${netTotal}-${bal_Total}
    ${discount_final_price}=  Convert To Number  ${discount_final_price}   2

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       ${bal_Total}

    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${discount_final_price}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${discount_final_price}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0

JD-TC-Apply SalesOrder discount-2

    [Documentation]   Create a sales Order with Valid Details and Genarate invoice then apply discount(calculationType is Percentage and discType is OnDemand).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Remove SalesOrder discount     ${SO_Uid}    ${discountId}    ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice2}=     Random Int   min=5   max=10
    ${discountprice2}=  Convert To Number  ${discountprice2}  1
    Set Suite Variable   ${discountprice2}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice2}   ${calctype[0]}  ${disctype[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId1}   ${resp.json()}   

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=40   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId1}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${bal_Total}=  Evaluate  ${netTotal}*${discountprice2}
    ${bal_Total}=  Convert To Number  ${bal_Total}   1
    ${bal_Total}=  Evaluate  ${bal_Total}/ 100

    ${discount_final_price}=  Evaluate  ${netTotal}-${bal_Total}
    ${discount_final_price}=  Convert To Number  ${discount_final_price}   1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       ${bal_Total}

    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${discount_final_price}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${discount_final_price}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0

JD-TC-Apply SalesOrder discount-3

    [Documentation]   Create a sales Order with Valid Details and Genarate invoice then apply discount(calculationType is Fixed and discType is Predifine).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ---------------------    Provider take a Sales Order -------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# --------------------     Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# --------------------     Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# --------------------     Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------
    # ${resp}=    Remove SalesOrder discount     ${SO_Uid}    ${discountId1}    ${discountprice2}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice3}=     Random Int   min=5   max=10
    ${discountprice3}=  Convert To Number  ${discountprice3}  1
    Set Suite Variable   ${discountprice3}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice3}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId2}   ${resp.json()}   

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId2}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${bal_Total}=  Evaluate  ${netTotal}-${discountprice3}
    ${bal_Total}=  Convert To Number  ${bal_Total}   1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       ${discountprice3}

    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0

JD-TC-Apply SalesOrder discount-4

    [Documentation]   Create a sales Order with Valid Details and Genarate invoice then apply discount(calculationType is Fixed and discType is OnDemand).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# --------------------     Provider take a Sales Order -------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# --------------------     Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# --------------------     Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# --------------------     Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------

    # ${resp}=    Remove SalesOrder discount     ${SO_Uid}    ${discountId2}    ${discountprice3}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice4}=     Random Int   min=5   max=10
    ${discountprice4}=  Convert To Number  ${discountprice4}  1
    Set Suite Variable   ${discountprice4}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice4}   ${calctype[1]}  ${disctype[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId3}   ${resp.json()}   

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=5   max=10
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId3}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${bal_Total}=  Evaluate  ${netTotal}-${discountValue1}
    ${bal_Total}=  Convert To Number  ${bal_Total}   1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       ${discountValue1}

    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0


JD-TC-Apply SalesOrder discount-5

    [Documentation]   Apply Discount with EMPTY privateNote.
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# -------------------      Provider take a Sales Order -------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# ------------------       Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# ------------------       Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# -----------------        Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=1   max=5
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId3}   ${EMPTY}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Apply SalesOrder discount-6

    [Documentation]   Apply Discount with EMPTY displayNote.
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ------------------        Provider take a Sales Order ------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# ------------------       Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# ------------------       Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# ------------------       Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=1   max=5
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId3}   ${privateNote}    ${EMPTY}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Apply SalesOrder discount-7

    [Documentation]   Create a SO then apply predifine discount,then update that sales order and get invoice then apply discount.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ---------------------    Provider take a Sales Order -------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# --------------------     Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# --------------------     Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# --------------------     Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice3}=     Random Int   min=5   max=10
    ${discountprice3}=  Convert To Number  ${discountprice3}  1
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice3}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${discountId2}   ${resp.json()}   

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=5   max=10
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${discountId2}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${bal_Total}=  Evaluate  ${netTotal}-${discountprice3}
    ${bal_Total}=  Convert To Number  ${bal_Total}   1

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                       ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                       ${discountprice3}

    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                       ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                      ${bal_Total}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0

    ${quantity1}=    Random Int  min=200   max=500

    ${netTotal}=  Evaluate  ${price}*${quantity1}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Update Order Items    ${SO_Uid}     ${SO_itemEncIds}    ${quantity1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${CAN_NOT_UPDATE_ORDER_IS_CONFIRMED}

    # ${resp}=    Get Sales Order    ${SO_Uid}   
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()['uid']}                                             ${SO_Uid}
    # Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    # Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
    # Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    # Should Be Equal As Strings    ${resp.json()['netRate']}                                         ${netTotal}

# --------------------------- Update SalesOrder Status ------------------------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[0]}
# ------------------------------------------------------------------------------------------------

    ${resp}=    Update Order Items    ${SO_Uid}     ${SO_itemEncIds}    ${quantity1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${netTotal}=  Evaluate  ${price}*${quantity1}
    ${netTotal}=  Convert To Number  ${netTotal}   2

    ${netTotalWithTax}=  Evaluate  ${netTotal}+0
    ${netTotalWithTax}=  Convert To Number  ${netTotalWithTax}   2

    ${netRate}=  Evaluate  ${netTotal}-${discountprice3}
    ${netRate}=  Convert To Number  ${netRate}   2

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                    ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                              ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                             ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                           ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                   ${discountprice3}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                        0.0
    Should Be Equal As Strings    ${resp.json()['netTotalWithTax']}                                 ${netTotalWithTax}
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                               0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                             0.0
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    Should Be Equal As Strings    ${resp.json()['netRate']}                                         ${netRate}
    Should Be Equal As Strings    ${resp.json()['amountDue']}                                       ${netRate}
    Should Be Equal As Strings    ${resp.json()['amountPaid']}                                      0.0
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                             0.0

JD-TC-Apply SalesOrder discount-8

    [Documentation]   Create a Inventory ON item and add to inventory catalog then create a sales order and create invoice and apply discount.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ---------------------  Create Item --------------------------------------

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${item1}  ${resp.json()}

# --------------------------------------------------------------------------

# ---------------------  create Inv Catalog -------------------------------
    ${INV_Cat_Name}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${INV_Cat_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Catalog_EncIds}  ${resp.json()}
# --------------------------------------------------------------------------

# -------------------    Create Inventory Catalog Item-----------------------

    ${resp}=   Create Inventory Catalog Item  ${Catalog_EncIds}   ${item1}  
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable   ${ic_Item_id}   ${resp.json()[0]}

# ---------------------------------------------------------------------------

# -------------------    Create SalesOrder Inventory Catalog-InvMgr True ---------
    ${Store_Name}=     FakerLibrary.name
    ${inv_cat_encid_List}=  Create List  ${Catalog_EncIds}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Store_Name}  ${boolean[1]}  ${inv_cat_encid_List}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_order_encid}  ${resp.json()}
# ---------------------------------------------------------------------------------------------------------
# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${inv_order_encid}    ${boolean[1]}     ${ic_Item_id}     ${price}    ${boolean[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

# ----------------------------------------------------------------------------------------------------------


JD-TC-Apply SalesOrder discount-UH1

    [Documentation]   Apply Discount with EMPTY discoutID.
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# -------------------      Provider take a Sales Order -------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# ------------------------------------------------------------------------------------
# -------------------      Update order status to ORDER_CONFIRMED---------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# ------------------       Create Sales Order Invoice---------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# ------------------------------------------------------------------------------------
# -------------------      Get Invoice By Invoice EncId ------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# ------------------------------------------------------------------------------------

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid}    ${EMPTY}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INCORRECT_DISCOUNT_ID}

JD-TC-Apply SalesOrder discount-UH2

    [Documentation]   Apply Discount with EMPTY discountValue.
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# ------------------       Provider take a Sales Order --------------------------------
    ${quantity}=    Random Int  min=2   max=5
    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom[5]}    ${items}     store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid1}  ${resp.json()}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    ${resp}=    Get Sales Order    ${SO_Uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid1}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
# -------------------------------------------------------------------------------------
# ------------------       Update order status to ORDER_CONFIRMED----------------------

    ${resp}=    Update SalesOrder Status    ${SO_Uid1}     ${orderStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid1}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[1]}

# -----------------        Create Sales Order Invoice----------------------------------

    ${resp}=    Create Sales Order Invoice    ${SO_Uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${SO_Inv}    ${resp.json()}  
# -------------------------------------------------------------------------------------
# -----------------        Get Invoice By Invoice EncId -------------------------------

    ${resp}=    Get Sales Order Invoice By Id    ${SO_Inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['order']['uid']}                                       ${SO_Uid1}
    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}

# -------------------------------------------------------------------------------------

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid1}    ${discountId3}   ${privateNote}    ${displayNote}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${CANNOT_APPLY_ZERO_DISC}

JD-TC-Apply SalesOrder discount-UH3

    [Documentation]    Try to Apply Discount without login.

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid1}    ${discountId3}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-Apply SalesOrder discount-UH4

    [Documentation]   Apply Discount with negative discountValue.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    # ${discountValue1}=     Random Int   min=-1   max=-10
    # ${discountValue1}=  Convert To Number  ${discountValue1}  1
    ${negative_number}=    Evaluate    -random.randint(1, 100)

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid1}    ${discountId3}   ${privateNote}    ${displayNote}   ${negative_number}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${CANNOT_APPLY_ZERO_DISC}

JD-TC-Apply SalesOrder discount-UH5

    [Documentation]    Try to Apply Discount with Provider Consumer login.

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=    Apply discount For SalesOrder    ${SO_Uid1}    ${discountId3}   ${privateNote}    ${displayNote}   ${discountValue1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   400
    Should Be Equal As Strings    ${resp.json()}        ${LOGIN_INVALID_URL}

