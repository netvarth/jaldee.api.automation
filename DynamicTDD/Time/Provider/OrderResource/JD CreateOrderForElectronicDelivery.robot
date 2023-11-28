*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${self}    0
${CUSERPH}      ${CUSERNAME}


*** Test Cases ***

JD-TC-CreateOrderForElectronicDelivery-1

    [Documentation]    Place an order for Electronic Delivery with virtual items only(walk-in).
    
    clear_queue    ${PUSERNAME160}
    clear_service  ${PUSERNAME160}
    clear_customer   ${PUSERNAME160}
    clear_Item   ${PUSERNAME160}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME160}
    Set Suite Variable  ${accId} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME160}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable   ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2        
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name 
    Set Suite Variable   ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 
    ${exp_date}=   db.add_timezone_date  ${tz}   4

    ${resp}=  Create Virtual Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}   ${itemType[1]}  ${exp_date}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}
    
    ${itemName2}=   FakerLibrary.firstname  
    Set Suite Variable   ${itemName2}
    ${itemCode2}=   FakerLibrary.lastname 
    ${displayName2}=   FakerLibrary.lastname 
    Set Suite Variable   ${displayName2}

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}
    
    ${itemName3}=   FakerLibrary.firstname  
    ${itemCode3}=   FakerLibrary.lastname 
    ${exp_date1}=   db.add_timezone_date  ${tz}   5
    ${displayName3}=   FakerLibrary.lastname 
    Set Suite Variable   ${displayName3}

    ${resp}=  Create Virtual Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}     ${itemType[1]}  ${exp_date1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}
    
    ${itemName4}=   FakerLibrary.firstname  
    ${itemCode4}=   FakerLibrary.lastname 
    ${exp_date2}=   db.add_timezone_date  ${tz}   2
    ${displayName4}=   FakerLibrary.lastname 
    Set Suite Variable   ${displayName4}

    ${resp}=  Create Virtual Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}     ${itemType[1]}  ${exp_date2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}
    
    ${itemName5}=   FakerLibrary.firstname  
    ${itemCode5}=   FakerLibrary.lastname 
    ${exp_date3}=   db.add_timezone_date  ${tz}   6
    ${displayName5}=   FakerLibrary.lastname 
    Set Suite Variable   ${displayName5}

    ${resp}=  Create Virtual Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemType[1]}  ${exp_date3}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    Set Suite Variable   ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=130
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=250
    Set Suite Variable   ${maxQuantity}

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable   ${cancelationPolicy}

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable   ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}
    Set Suite Variable   ${pickupSchedule}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable   ${pickUp}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    Set Suite Variable   ${homeDelivery}
    
    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable   ${orderStatuses}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}    itemType=VIRTUAL   expiryDate=${exp_date}    displayName=${displayName1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}   
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}  
    Set Suite Variable   ${catalogItem}
    ${catalogItem4}=  Create List    ${catalogItem2}    
    Set Suite Variable   ${catalogItem4}
    ${catalogItem3}=  Create List   ${catalogItem1}    ${catalogItem2}
    Set Suite Variable   ${catalogItem3}

    ${vir_items1}=  Create Dictionary  itemId=${item_id3}    itemType=VIRTUAL   expiryDate=${exp_date1}   displayName=${displayName3}
    ${vir_items2}=  Create Dictionary  itemId=${item_id4}    itemType=VIRTUAL   expiryDate=${exp_date2}   displayName=${displayName4}
    ${vir_items3}=  Create Dictionary  itemId=${item_id5}    itemType=VIRTUAL   expiryDate=${exp_date3}   displayName=${displayName5}
    ${virtual_item_cat1}=  Create Dictionary  item=${vir_items1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${virtual_item_cat2}=  Create Dictionary  item=${vir_items2}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${virtual_item_cat3}=  Create Dictionary  item=${vir_items3}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${virtual_catalog_item}=  Create List   ${virtual_item_cat1}    ${virtual_item_cat2}   ${virtual_item_cat3}
    Set Suite Variable   ${virtual_catalog_item}

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable   ${advanceAmount}
   
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${catalogName1}=   FakerLibrary.firstname  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem4}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   pickUp=${pickUp} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${catalogName3}=   FakerLibrary.name  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem3}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   pickUp=${pickUp}    homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${catalogName4}=   FakerLibrary.lastname  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem3}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   pickUp=${pickUp}    homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME10}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid10}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${orderNote}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For Electronic Delivery    ${cookie}  ${cid10}   ${cid10}   ${CatalogId1}   ${DAY1}    ${CUSERNAME10}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateOrderForElectronicDelivery-UH1

    [Documentation]    Place an order for electronic Delivery with expired virtual items.
    
    change_system_date   6
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${orderNote}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_ITEM_ADDED}=   Format String  ${INVALID_ITEM_ADDED}  ${displayName1}  

    ${resp}=   Create Order By Provider For Electronic Delivery    ${cookie}  ${cid10}   ${cid10}   ${CatalogId1}   ${DAY1}    ${CUSERNAME10}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_ITEM_ADDED}

    resetsystem_time

JD-TC-CreateOrderForElectronicDelivery-UH2

    [Documentation]   try to add an expired item to catalog.
    
    change_system_date   -6
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1}=   FakerLibrary.word 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2        
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName11}=   FakerLibrary.word 
    Set Suite Variable   ${itemName11}
   
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 
    ${exp_date}=   db.add_timezone_date  ${tz}   4

    ${resp}=  Create Virtual Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName11}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}   ${itemType[1]}  ${exp_date}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${exp_item_id1}  ${resp.json()}
    resetsystem_time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item1_Id}=  Create Dictionary  itemId=${exp_item_id1}    itemType=VIRTUAL   expiryDate=${exp_date}   displayName=${displayName1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}  
    ${catalogName}=   FakerLibrary.word  
    ${catalogDesc}=   FakerLibrary.lastname 
    
    ${VIRTUAL_ITEM_EXPIRED_CATALOG}=   Format String  ${VIRTUAL_ITEM_EXPIRED_CATALOG}  ${displayName1}  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${VIRTUAL_ITEM_EXPIRED_CATALOG}

    resetsystem_time
    
JD-TC-CreateOrderForElectronicDelivery-UH3

    [Documentation]   try to remove an expired item from catalog.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${exp_item_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CATALOG_ITEM_NOT_FOUND}

    
JD-TC-CreateOrderForElectronicDelivery-UH4

    [Documentation]    create an order for virtual items in which one item is expired.

    change_system_date   4
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${orderNote}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_ITEM_ADDED}=   Format String  ${INVALID_ITEM_ADDED}  ${displayName3}  

    ${resp}=   Create Order By Provider For Electronic Delivery    ${cookie}  ${cid10}   ${cid10}   ${CatalogId4}   ${DAY1}    ${CUSERNAME10}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}  ${item_id5}   ${item_quantity1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_ITEM_ADDED}
    resetsystem_time

JD-TC-CreateOrderForElectronicDelivery-UH5

    [Documentation]    try to update an order in which the item is expired after taking the order.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${orderNote}

    ${INVALID_ITEM_ADDED}=   Format String  ${INVALID_ITEM_ADDED}  ${displayName3} 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For Electronic Delivery    ${cookie}  ${cid10}   ${cid10}   ${CatalogId1}   ${DAY1}    ${CUSERNAME10}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_ITEM_ADDED}
    
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${orderid1}  ${orderid[0]}

    # ${resp}=   Get Order by uid    ${orderid1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # change_system_date   6
    
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${firstname2}=  FakerLibrary.first_name
    # Set Test Variable  ${email1}  ${firstname2}${CUSERPH}.${test_mail}
    
    # sleep  1s
    # ${resp}=   Update Order For Electronic Delivery   ${orderid1}   ${DAY1}    ${CUSERNAME11}   ${email1}  ${countryCodes[1]}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Order by uid    ${orderid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    resetsystem_time