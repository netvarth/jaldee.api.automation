*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ORDER ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Create_Catalog_For_ShoppingCart-1

    [Documentation]  Provider Create order catalog

    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${shortDesc1}   
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Suite Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300 
    Set Suite Variable  ${price1}
    ${price1float}=  twodigitfloat  ${price1}
    Set Suite Variable  ${price1float}
    ${price2float}=   Convert To Number   ${price1}  2
    Set Suite Variable  ${price2float}

     
    ${itemName1}=   FakerLibrary.name
    Set Suite Variable  ${itemName1}   

    ${itemName2}=   FakerLibrary.name
    Set Suite Variable  ${itemName2}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal1}  
 
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Suite Variable  ${promoPrice1float}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}   
    ${itemCode1}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode1}  

    ${itemCode2}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode2}   
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid2}  ${resp.json()}

    # ${resp}=   Get Item By Id  ${Pid1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[0]}   isStockAvailable=${bool[0]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[0]}   itemCode=${itemCode1}    
    # #  promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1} 


    # ${resp}=   Get Item By Id  ${Pid2} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
 
    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate}

    # ${noOfOccurance}=  Random Int  min=0   max=10
    # Set Suite Variable  ${noOfOccurance}

    Set Suite Variable  ${noOfOccurance}   0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title} 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text}

    ${minQuantity}=  Random Int  min=1   max=3
    Set Suite Variable  ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable  ${maxQuantity}

    ${catalogName}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName} 

    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc} 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy} 


    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    # -----------------------
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    # -----------------------
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    Set Suite Variable  ${homeDelivery}
    # -----------------------
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    # -----------------------
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    # -----------------------
    ${orderStatus_list}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${orderStatus_list}
    # -----------------------
    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    Set Suite Variable  ${catalogItem}
    # -----------------------
    

    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}

    ${far}=  Random Int  min=1   max=1000
    Set Suite Variable  ${far}

    ${soon}=  Random Int  min=1   max=1000
    Set Suite Variable  ${soon}

    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName1}

    ${resp}=  Get Catalog By Criteria   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-Create_Catalog_For_ShoppingCart-2
    [Documentation]  Allow Store_Pickup only and Create order catalog for SHOPPINGCART 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName3}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName3}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create_Catalog_For_ShoppingCart-3
    [Documentation]  Allow Home_delivery only and Create order catalog for SHOPPINGCART 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName4}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName4}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create_Catalog_For_ShoppingCart-UH1
    [Documentation]  Provider Create order catalog without using Store_Pickup and Home_delivery details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DELIVERY_OPTION_REQUIRED}"


JD-TC-Create_Catalog_For_ShoppingCart-UH2
    [Documentation]  Provider Create order catalog again using same details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName5}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName5}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}  homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}  pickUp=${pickUp}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_NAME_SHOULD_BE_UNIQUE}"
    
    ${catalogName6}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName6}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName6}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId6}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId6}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName6}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_NAME_SHOULD_BE_UNIQUE}"

    ${resp}=  Create Catalog For ShoppingList   ${catalogName6}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${orderStatus_list}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_NAME_SHOULD_BE_UNIQUE}"



JD-TC-Create_Catalog_For_ShoppingCart-UH3
    [Documentation]  Provider Create order catalog again using same details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${DuplicateItems}=  Create List   ${catalogItem1}   ${catalogItem1}
    Set Suite Variable  ${DuplicateItems}
    
    ${catalogName8}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName8}

    ${DUPLICATE_ITEM_FOUND}=  Format String   ${DUPLICATE_ITEM_INPUT}    ${Pid1}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName8}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${DuplicateItems}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_ITEM_FOUND}"

   
  
JD-TC-Create_Catalog_For_ShoppingCart-UH4
    [Documentation]  Provider Create order catalog for SHOPPINGLIST and add items details 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName47}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName47}

    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    ${resp}=  Create Catalog For ShoppingList   ${catalogName47}  ${EMPTY}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${orderStatus_list}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogItem=${catalogItem}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${UNABLE_TO_ADD_ITEMS}"



JD-TC-Create_Catalog_For_ShoppingCart-UH5
    [Documentation]  Provider Create order catalog for SHOPPINGCART using Minimum_Number_of_item as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName7}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName7}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${EMPTY}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${MIN_NUMBER_ITEM_REQUIRED}"



JD-TC-Create_Catalog_For_ShoppingCart-UH6
    [Documentation]  Provider Create order catalog for SHOPPINGCART using Maximum_Number_of_item as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName10}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName10}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName10}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${EMPTY}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId14}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId14}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create_Catalog_For_ShoppingCart-UH7
    [Documentation]  Provider Create order catalog for SHOPPINGCART using CancelationPolicy as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName11}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName11}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName11}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${EMPTY}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANCELLATION_POLICY_REQUIRED}"



JD-TC-Create_Catalog_For_ShoppingCart-UH8
    [Documentation]  Create catalog using invalid item_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 
    ${INVALID_item_id}=  Create Dictionary  itemId=${Invalid_id}
    ${INVALIDItem}=  Create Dictionary  item=${INVALID_item_id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${INVALID_CatalogItem}=  Create List   ${INVALIDItem}

    ${UNABLE_TO_ADD_INVALID_ITEM1}=  Format String   ${UNABLE_TO_ADD_INACTIVE_ITEMS}    Item id ${Invalid_id} is invalid     invalid item
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${INVALID_CatalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${UNABLE_TO_ADD_INVALID_ITEM1}"

    ${Invalid_id1}=  Random Int  min=100000   max=300000 
    ${INVALID_item_id1}=  Create Dictionary  itemId=${Invalid_id1}
    ${INVALIDItem1}=  Create Dictionary  item=${INVALID_item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    
    ${Invalid_id2}=  Random Int  min=300000   max=500000 
    ${INVALID_item_id2}=  Create Dictionary  itemId=${Invalid_id2}
    ${INVALIDItem2}=  Create Dictionary  item=${INVALID_item_id2}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${INVALID_CatalogItem2}=  Create List   ${INVALIDItem1}   ${INVALIDItem2}

    ${UNABLE_TO_ADD_INVALID_ITEM2}=  Format String   ${UNABLE_TO_ADD_INACTIVE_ITEMS}    Item id's ${Invalid_id1},${Invalid_id2} are invalid      invalid items
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${INVALID_CatalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${UNABLE_TO_ADD_INVALID_ITEM2}"



JD-TC-Create_Catalog_For_ShoppingCart-UH9
    [Documentation]   Create catalog Without login

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Create_Catalog_For_ShoppingCart-UH10
    [Documentation]   Login as consumer and Create catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Create_Catalog_For_ShoppingCart-UH11
    [Documentation]   A provider try to Create catalog using another providers item deatils
    clear_Item  ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-Create_Catalog_For_ShoppingCart-UH12
    [Documentation]  Provider Create order catalog without using ORDER_CONFIRMED status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_orderStatus}=  Create List  ${orderStatuses[0]}  ${orderStatuses[9]}  ${orderStatuses[12]}
   
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${INVALID_orderStatus}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId7}   ${resp.json()}
    # Should Be Equal As Strings  "${resp.json()}"  "${ORDER_STATUS_CONFIRMED_REQUIRED}"
    ${resp}=  Get Order Catalog    ${CatalogId7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create_Catalog_For_ShoppingCart-UH13
    [Documentation]  Provider Create order catalog without using ORDER_RECEIVED status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_orderStatus}=  Create List  ${orderStatuses[2]}   ${orderStatuses[9]}  ${orderStatuses[12]}
    
    ${catalogName37}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName37}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName37}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${INVALID_orderStatus}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_STATUS_ORDERRECEIVED_REQUIRED}"
    


JD-TC-Create_Catalog_For_ShoppingCart-UH14
    [Documentation]  Provider Create order catalog without using ORDER_CANCELED status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_orderStatus}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[9]}
    
    ${catalogName27}=   FakerLibrary.lastname 
    Set Suite Variable  ${catalogName27}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName27}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${INVALID_orderStatus}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_STATUS_CANCEL_REQUIRED}"


# JD-TC-Create_Catalog_For_ShoppingCart-UH14
#     [Documentation]  Provider Create order catalog when store_pickup schedule startDate is EMPTY
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${INVALID_Schedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${EMPTY}   terminator=${terminator}   timeSlots=${timeSlots}

#     ${INVALID_pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${INVALID_Schedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}


#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName12}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${INVALID_pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422



# JD-TC-Create_Catalog_For_ShoppingCart-UH15
#     [Documentation]  Provider Create order catalog when store_pickup schedule endDate is EMPTY
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${terminator}=  Create Dictionary  endDate=${EMPTY}  noOfOccurance=${noOfOccurance}
#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${INVALID_Schedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}

#     ${INVALID_pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${INVALID_Schedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName13}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${INVALID_pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422



# JD-TC-Create_Catalog_For_ShoppingCart-UH16
#     [Documentation]  Provider Create order catalog when homedelivery schedule startDate is EMPTY
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${INVALID_Schedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${EMPTY}   terminator=${terminator}   timeSlots=${timeSlots}

#     ${INVALIDhomeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${INVALID_Schedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName15}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${INVALIDhomeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422



# JD-TC-Create_Catalog_For_ShoppingCart-UH17
#     [Documentation]  Provider Create order catalog when homedelivery schedule endDate is EMPTY
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${terminator}=  Create Dictionary  endDate=${EMPTY}  noOfOccurance=${noOfOccurance}
#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${INVALID_Schedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}

#     ${INVALIDhomeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${INVALID_Schedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName16}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${INVALIDhomeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Create_Catalog_For_ShoppingCart-UH15
    [Documentation]  Provider Create order catalog using Minimum_Quantity of item as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${INVALID_Item}=  Create Dictionary  item=${item1_Id}    minQuantity=${EMPTY}   maxQuantity=${maxQuantity}  
    # ${INVALID_Item}=  Create Dictionary  item=${item1_Id}    maxQuantity=${maxQuantity}  
    
    ${INVALID_Item_List}=  Create List   ${INVALID_Item}
    ${catalogName19}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName19}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName19}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatuses}   ${INVALID_Item_List}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
  


JD-TC-Create_Catalog_For_ShoppingCart-4
    [Documentation]  Provider Create order catalog using Maximum_Quantity of item as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${INVALID_Item}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${EMPTY}  
    ${INVALID_Item_List}=  Create List   ${INVALID_Item}
   
    ${catalogName20}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName20}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName20}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatuses}   ${INVALID_Item_List}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId25}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId25}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 


JD-TC-Create_Catalog_For_ShoppingCart-5
    [Documentation]  Provider Create order catalog when deliveryCharge is EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${VALID_Schedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}

    ${INVALIDhomeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${VALID_Schedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${EMPTY}
    ${catalogName18}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName18}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName18}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${INVALIDhomeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId26}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId26}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create_Catalog_For_ShoppingCart-UH16
    [Documentation]   Provider try to Create order catalog using advance amount when Advanced_Payment_Type is FULL_AMOUNT

    clear_queue    ${PUSERNAME12}
    clear_service  ${PUSERNAME12}
    clear_customer   ${PUSERNAME12}
    clear_Item   ${PUSERNAME12}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid2}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId11}=  get_acc_id  ${PUSERNAME12}
    Set Suite Variable  ${accId11}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id2}  ${firstname}${PUSERNAME12}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable    ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime2}  
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity2}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable   ${maxQuantity2}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${catalogItem}=  Create List   ${catalogItem1}
    

    Set Test Variable  ${paymentType3}     ${AdvancedPaymentType[2]}


    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType3}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ADVANCE_AMOUNT_NOT_REQUIRED}"




JD-TC-Create_Catalog_For_ShoppingCart-6
    [Documentation]   Provider Create order catalog using autoConfirm as true

    clear_queue    ${PUSERNAME12}
    clear_service  ${PUSERNAME12}
    clear_customer   ${PUSERNAME12}
    clear_Item   ${PUSERNAME12}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    # ${accId11}=  get_acc_id  ${PUSERNAME12}
    # Set Suite Variable  ${accId11}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id2}  ${firstname}${PUSERNAME12}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
 
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable    ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime2}  
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity2}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable   ${maxQuantity2}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${catalogItem}=  Create List   ${catalogItem1}
    

    Set Test Variable  ${paymentType3}     ${AdvancedPaymentType[2]}


    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType3}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId27}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId27}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Create_Catalog_For_ShoppingCart-7
    [Documentation]   Provider Create order catalog using autoConfirm as true, But Order Received status has not given

    clear_queue    ${PUSERNAME12}
    clear_service  ${PUSERNAME12}
    clear_customer   ${PUSERNAME12}
    clear_Item   ${PUSERNAME12}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    # ${accId11}=  get_acc_id  ${PUSERNAME12}
    # Set Suite Variable  ${accId11}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id2}  ${firstname}${PUSERNAME12}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
 
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable    ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime2}  
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity2}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable   ${maxQuantity2}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    # ${StatusesList}=  Create List   ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${orderStatus_list} =  Create List  ${orderStatuses[0]}   ${orderStatuses[2]}   ${orderStatuses[3]}   ${orderStatuses[11]}   ${orderStatuses[12]}
    ${catalogItem}=  Create List   ${catalogItem1}
    

    Set Test Variable  ${paymentType3}     ${AdvancedPaymentType[2]}


    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType3}     ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId27}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId27}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



