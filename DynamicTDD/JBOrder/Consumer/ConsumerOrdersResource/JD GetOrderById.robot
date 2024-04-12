*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
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

*** Keywords ***

Get Order Time
    [Arguments]   ${i}   ${resp}
    @{stimes}=  Create List
    @{etimes}=  Create List
    ${len}=  Get Length  ${resp.json()[${i}]['timeSlots']}
    FOR  ${j}  IN RANGE  0    ${len}
      
        Append To List   ${stimes}   ${resp.json()[${i}]['timeSlots'][${j}]['sTime']}
        Append To List   ${etimes}   ${resp.json()[${i}]['timeSlots'][${j}]['eTime']}
    END
    RETURN    ${stimes}     ${etimes}


*** Test Cases ***

JD-TC-GetOrderById-1
    [Documentation]    Get an order details for home delivery.

    clear_queue    ${PUSERNAME150}
    clear_service  ${PUSERNAME150}
    clear_customer   ${PUSERNAME150}
    clear_Item   ${PUSERNAME150}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME150}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME150}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14

    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=1   max=1

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery  ${cookie}  ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    # Set Test Variable  ${jaldee_id}  ${resp.json()[0]['jaldeeConsumer']}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}              ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}  ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                         ${soon_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}             ${far_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}             ${sTime1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}             ${eTime1}
    Should Be Equal As Strings  ${resp.json()['isAsap']}                                               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['isFirstOrder']}                                         ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['orderMode']}                                            ONLINE_ORDER
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}                                          ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['email']}                                                ${email}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      0.0
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}                                    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}                                    ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['cartAmount']}                                         ${ph_no}
    # Should Be Equal As Strings  ${resp.json()['deliveryCharge']}                                     ${ph_no}

JD-TC-GetOrderById-2
    [Documentation]    Get an order details for store pickup.

    clear_queue    ${PUSERNAME151}
    clear_service  ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}
    clear_Item   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME151}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME151}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14

    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=1   max=1

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${resp}=   Create Order For Pickup  ${cookie}  ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    # Set Test Variable  ${jaldee_id}  ${resp.json()[0]['jaldeeConsumer']}
    
    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    Verify Response    ${resp}  homeDelivery=${bool[0]}    uid=${orderid1}  storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}              ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}  ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                         ${soon_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}             ${far_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}             ${sTime1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}             ${eTime1}
    Should Be Equal As Strings  ${resp.json()['isAsap']}                                               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['isFirstOrder']}                                         ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['orderMode']}                                            ONLINE_ORDER
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}                                          ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                                                ${email}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      0.0
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}                                    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}                                    ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['cartAmount']}                                         ${ph_no}
    # Should Be Equal As Strings  ${resp.json()['deliveryCharge']}                                     ${ph_no}

JD-TC-GetOrderById-3
    [Documentation]    Get order By Consumer for Home Delivery without doing advance payment.

    clear_queue    ${PUSERNAME152}
    clear_service  ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}
    clear_Item   ${PUSERNAME152}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME152}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME152}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=50
   
    ${far}=  Random Int  min=14  max=14
   
    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=1   max=1

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME27}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME27}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME27}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME27}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[1]}   orderDate=${DAY1}   
    ...    advanceAmountPaid=0.0    advanceAmountToPay=${advanceAmount}.0
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}              ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}  ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                         ${soon_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}             ${far_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}             ${sTime1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}             ${eTime1}
    Should Be Equal As Strings  ${resp.json()['isAsap']}                                               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['isFirstOrder']}                                         ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['orderMode']}                                            ONLINE_ORDER
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}                                          ${CUSERNAME27}
    Should Be Equal As Strings  ${resp.json()['email']}                                                ${email}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      0.0
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}                                    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}                                    ${eTime1}


JD-TC-GetOrderById-4
    [Documentation]    Get order By Consumer for Home Delivery and do the advance payment.

    clear_queue    ${PUSERNAME134}
    clear_service  ${PUSERNAME134}
    clear_customer   ${PUSERNAME134}
    clear_Item   ${PUSERNAME134}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME134}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME134}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=100
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=5

    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME25}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME25}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME25}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cid}=  get_id  ${CUSERNAME25}
    Set Test Variable   ${cid}

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[1]}  orderDate=${DAY1}   
    ...    advanceAmountPaid=0.0    advanceAmountToPay=${advanceAmount}.0
    
    ${resp}=  Make payment Consumer Mock  ${accId}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${advanceAmount}  ${bool[1]}  ${orderid1}  ${pid}  ${purpose[0]}  ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[0]}   orderDate=${DAY1} 
    ...    advanceAmountPaid=${advanceAmount}.0    advanceAmountToPay=${advanceAmount}.0

JD-TC-GetOrderById-5
    [Documentation]    Place an order By Consumer for Home Delivery and do a failed advance payment.

    clear_queue    ${PUSERNAME155}
    clear_service  ${PUSERNAME155}
    clear_customer   ${PUSERNAME155}
    clear_Item   ${PUSERNAME155}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME155}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME155}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=5

    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cid}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid}

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[1]}   orderDate=${DAY1}   
    Set Test Variable   ${advanceAmount}   ${resp.json()['advanceAmountToPay']}
    
    ${resp}=  Make payment Consumer Mock  ${accId}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${advanceAmount}  ${bool[0]}  ${orderid1}  ${pid}  ${purpose[0]}  ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${mer2}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref2}   ${resp.json()['paymentRefId']}
    
    sleep   2s
    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[0]}   orderDate=${DAY1}   

JD-TC-GetOrderById-6
    [Documentation]    Get order By Consumer for pickup without doing advance payment.

    clear_queue    ${PUSERNAME160}
    clear_service  ${PUSERNAME160}
    clear_customer   ${PUSERNAME160}
    clear_Item   ${PUSERNAME160}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME160}

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

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=1   max=1

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'          
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}
    
    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME10}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[0]}    uid=${orderid1}  storePickup=${bool[1]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[1]}   orderDate=${DAY1}   
    ...    advanceAmountPaid=0.0    advanceAmountToPay=${advanceAmount}.0

    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}              ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}  ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                         ${soon_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}             ${far_date}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}             ${sTime1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}             ${eTime1}
    Should Be Equal As Strings  ${resp.json()['isAsap']}                                               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['isFirstOrder']}                                         ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['orderMode']}                                            ONLINE_ORDER
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}                                          ${CUSERNAME10}
    Should Be Equal As Strings  ${resp.json()['email']}                                                ${email}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      0.0
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}                                    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}                                    ${eTime1}


JD-TC-GetOrderById-UH1
    [Documentation]    Place an order By Consumer for Home Delivery and do the advance payment twice.

    clear_queue    ${PUSERNAME156}
    clear_service  ${PUSERNAME156}
    clear_customer   ${PUSERNAME156}
    clear_Item   ${PUSERNAME156}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME156}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME156}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=5

    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cid}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid}

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=${orderInternalStatus[1]}   orderDate=${DAY1}   

    ${advcamt}=  Evaluate  ${item_quantity1} * ${promoPrice1} + ${deliveryCharge}

    ${admount}=   Set Variable If  ${advanceAmount} > ${advcamt}   ${advcamt}   ${advanceAmount}

    ${resp}=  Make payment Consumer Mock  ${accId}  ${admount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${admount}  ${bool[1]}  ${orderid1}  ${pid}  ${purpose[0]}  ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  3s
    ${resp}=  Make payment Consumer Mock  ${accId}  ${admount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${admount}  ${bool[1]}  ${orderid1}  ${pid}  ${purpose[0]}  ${cid}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${PAYMENT_ALREADY_PROCESSED}"

JD-TC-GetOrderById-UH2
    [Documentation]    Get Order by provider login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"

JD-TC-GetOrderById-UH3
    [Documentation]    Get Order without login.

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"

JD-TC-GetOrderById-UH4
    [Documentation]    Get Order by provider login.
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"

JD-TC-GetOrderById-UH5
    [Documentation]    Place an order By Consumer for Home Delivery and do the advance payment with amount less than the advance amount.

    clear_queue    ${PUSERNAME156}
    clear_service  ${PUSERNAME156}
    clear_customer   ${PUSERNAME156}
    clear_Item   ${PUSERNAME156}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME156}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME156}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  30     

    ${sTime2}=  add_timezone_time  ${tz}  2  00  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     

    ${sTime3}=  add_timezone_time  ${tz}  4  00  
    ${eTime3}=  add_timezone_time  ${tz}  5  00     

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}

    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=5

    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${DAY1}=  db.add_timezone_date  ${tz}  12  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cid}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid}

    ${amountpaid}=  Evaluate  ${advanceAmount} - 10

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=PREPAYMENTPENDING   orderDate=${DAY1}   

    ${resp}=  Make payment Consumer Mock  ${pid}  ${amountpaid}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${amountpaid}  ${bool[1]}  ${orderid1}  ${pid}  ${purpose[0]}  ${cid}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${PREPAYMENT_AMOUNT_MISMATCH_FROM_ORDER_CREATED}"
   

