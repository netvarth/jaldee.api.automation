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

JD-TC-Getorderbyid-1
    [Documentation]   Get an order By id.(homedelivery)
    
    clear_queue    ${PUSERNAME140}
    clear_service  ${PUSERNAME140}
    clear_customer   ${PUSERNAME140}
    clear_Item   ${PUSERNAME140}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}

    ${accId1}=  get_acc_id  ${PUSERNAME140}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME140}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
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
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

 
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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}

    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}  max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId1}   ${orderid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jcons_id1}  ${resp.json()[0]['jaldeeId']}

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${cartAmount}=   Evaluate  ${totalprice} + ${deliveryCharge}
    ${cartAmount}=  Convert To Number  ${cartAmount}  1

    ${resp}=   Get Order by uid   ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   

    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}             ${accId1}
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}   ${bsname}

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}              ${jcons_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}        ${jdconID}

    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                                         ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}                        ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}            ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}            ${sTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}            ${eTime1}
    Should Be Equal As Strings  ${resp.json()['catalog']['advanceAmount']}                                       0.0

    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}

    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                        ${startDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}            ${endDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}            ${sTime1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}            ${eTime1}
   
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}                             ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime1}

    Should Be Equal As Strings  ${resp.json()['isAsap']}                    ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}              ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['coupons']}                   []
    Should Be Equal As Strings  ${resp.json()['orderMode']}                 ${order_mode[1]}    
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['advanceAmountPaid']}         0.0
    Should Be Equal As Strings  ${resp.json()['advanceAmountToPay']}        0.0
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}           0.0
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    Should Be Equal As Strings  ${resp.json()['deliveryCharge']}            ${deliveryCharge}
    # Should Be Equal As Strings  ${resp.json()['accesScope']}                ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['account']}                   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['onlineRequest']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['kioskRequest']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['firstCheckIn']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['active']}                    ${bool[0]} 


JD-TC-GetOrderById-2
    [Documentation]    Get an order details for store pickup.

    clear_queue    ${PUSERNAME141}
    clear_service  ${PUSERNAME141}
    clear_customer   ${PUSERNAME141}
    clear_Item   ${PUSERNAME141}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid2}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname1}  ${resp.json()['businessName']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME141}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME141}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id}
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
    Set Test Variable  ${item_id2}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    ${eTime2}=  add_timezone_time  ${tz}  3  30     
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

    ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[3]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
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
    Set Test Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId2}    ${self}    ${CatalogId2}   ${bool[1]}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${j_id1}  ${resp.json()[0]['jaldeeId']}
    # Set Test Variable  ${cons_id1}  ${resp.json()[consumer]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId2}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1


    Verify Response    ${resp}  homeDelivery=${bool[0]}    uid=${orderid2}  storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId2}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid   ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   

    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 

    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}             ${accId2}
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}   ${bsname1}

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}            ${j_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}        ${jaldee_id1}

    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                                         ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}                        ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}            ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}            ${sTime2}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}            ${eTime2}
    Should Be Equal As Strings  ${resp.json()['catalog']['advanceAmount']}                                       0.0

    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}

    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                        ${startDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}            ${endDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}            ${sTime2}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}            ${eTime2}
   
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}                              ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime2}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime2}

    Should Be Equal As Strings  ${resp.json()['isAsap']}                    ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}              ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['coupons']}                   []
    Should Be Equal As Strings  ${resp.json()['orderMode']}                 ${order_mode[1]}    
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['advanceAmountPaid']}         0.0
    Should Be Equal As Strings  ${resp.json()['advanceAmountToPay']}        0.0
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}           0.0
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${totalPrice}
    # Should Be Equal As Strings  ${resp.json()['accesScope']}                ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['account']}                   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['onlineRequest']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['kioskRequest']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['firstCheckIn']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['active']}                    ${bool[0]} 

JD-TC-GetOrderById-3
    [Documentation]    get a family member's order.

    clear_queue    ${PUSERNAME143}
    clear_service  ${PUSERNAME143}
    clear_customer   ${PUSERNAME143}
    clear_Item   ${PUSERNAME143}
    # clear_customer   ${PUSERNAME143}
     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME143}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname1}  ${resp.json()['businessName']}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME143}.${test_mail}

    ${resp}=  Update Email   ${pid0}   ${firstname}   ${lastname}   ${email_id}
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
    Set Test Variable  ${item_id0}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    ${eTime0}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity0}=  Random Int  min=1   max=30

    ${maxQuantity0}=  Random Int  min=${minQuantity0}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime0}   eTime=${eTime0}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    

    ${fname1}=  FakerLibrary.first_name
    ${lname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember  ${fname1}  ${lname1}  ${dob}  ${gender}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
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

    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId0}    ${mem_id}    ${CatalogId}     ${bool[1]}    ${address}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERNAME1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${j_id1}  ${resp.json()[1]['jaldeeId']}
    # Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${cartAmount}=   Evaluate  ${totalprice} + ${deliveryCharge}
    ${cartAmount}=  Convert To Number  ${cartAmount}  1

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId0}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                                ${catalogName}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}             ${accId0}
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}   ${bsname1}

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}              ${j_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}        ${jaldee_id1}

    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                                         ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}                        ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}            ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}            ${sTime0}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}            ${eTime0}
    Should Be Equal As Strings  ${resp.json()['catalog']['advanceAmount']}                                       0.0

    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname1}

    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                        ${startDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}            ${endDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}            ${sTime0}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}            ${eTime0}
   
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}                             ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime0}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime0}

    Should Be Equal As Strings  ${resp.json()['isAsap']}                    ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}              ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['coupons']}                   []
    Should Be Equal As Strings  ${resp.json()['orderMode']}                 ${order_mode[1]}    
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['advanceAmountPaid']}         0.0
    Should Be Equal As Strings  ${resp.json()['advanceAmountToPay']}        0.0
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}           0.0
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    Should Be Equal As Strings  ${resp.json()['deliveryCharge']}            ${deliveryCharge}
    # Should Be Equal As Strings  ${resp.json()['accesScope']}                ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['account']}                   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['onlineRequest']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['kioskRequest']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['firstCheckIn']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['active']}                    ${bool[0]} 


JD-TC-GetOrderById-4
    [Documentation]    Get an order By provider for today.

    clear_queue    ${PUSERNAME143}
    clear_service  ${PUSERNAME143}
    clear_customer   ${PUSERNAME143}
    clear_Item   ${PUSERNAME143}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname1}  ${resp.json()['businessName']}


    ${accId0}=  get_acc_id  ${PUSERNAME143}

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
    Set Test Variable  ${item_id0}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    ${eTime0}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity0}=  Random Int  min=1   max=30

    ${maxQuantity0}=  Random Int  min=${minQuantity0}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime0}   eTime=${eTime0}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[3]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${address}=  get_address
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

    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId0}    ${self}    ${CatalogId}     ${bool[1]}    ${address}    ${sTime0}    ${eTime0}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId0}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jcons_id1}  ${resp.json()[0]['jaldeeId']}


    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${cartAmount}=   Evaluate  ${totalprice} + ${deliveryCharge}
    ${cartAmount}=  Convert To Number  ${cartAmount}  1


    ${resp}=   Get Order by uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   

    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}             ${accId0}
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}   ${bsname1}

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}              ${jcons_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}        ${jaldee_id1}

    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                                         ${catalogName}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}                        ${startDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}            ${endDate}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}            ${sTime0}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}            ${eTime0}
    Should Be Equal As Strings  ${resp.json()['catalog']['advanceAmount']}                                       0.0

    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}

    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['recurringType']}                    ${recurringtype[1]} 
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                        ${startDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['repeatIntervals']}                  ${list}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}            ${endDate1}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['noOfOccurance']}      0
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}            ${sTime0}
    Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}            ${eTime0}
   
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}                             ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime0}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime0}

    Should Be Equal As Strings  ${resp.json()['isAsap']}                    ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}              ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['coupons']}                   []
    Should Be Equal As Strings  ${resp.json()['orderMode']}                 ${order_mode[1]}    
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['advanceAmountPaid']}         0.0
    Should Be Equal As Strings  ${resp.json()['advanceAmountToPay']}        0.0
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}           0.0
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    Should Be Equal As Strings  ${resp.json()['deliveryCharge']}            ${deliveryCharge}
    # Should Be Equal As Strings  ${resp.json()['accesScope']}                ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['account']}                   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['onlineRequest']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['kioskRequest']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['firstCheckIn']}              ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['active']}                    ${bool[0]} 


JD-TC-GetOrderById-5
    [Documentation]    Place an order By Consumer for pickup.
    
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_customer   ${PUSERNAME200}
    clear_Item   ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME200}
    Set Test Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME200}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${displayName3}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    
    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Test Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Test Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id4}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    
    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50

    ${catalogDesc}=   FakerLibrary.name 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Test Variable  ${catalogItem}
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Test Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${soon}
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${catalogName2}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    

JD-TC-GetOrderById-6
    [Documentation]    Get order By Consumer for Home Delivery without doing advance payment.

    clear_queue    ${PUSERNAME154}
    clear_service  ${PUSERNAME154}
    clear_customer   ${PUSERNAME154}
    clear_Item   ${PUSERNAME154}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If   ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}     Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    
    ${accId}=  get_acc_id  ${PUSERNAME154}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME154}.${test_mail}

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
    # ${address}=  get_address
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
  
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  
    ...    orderStatus=${orderStatuses[0]}  orderInternalStatus=PREPAYMENTPENDING   orderDate=${DAY1}   
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
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}                                         ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['orderMode']}                                            ONLINE_ORDER
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}                                          ${CUSERNAME19}
    Should Be Equal As Strings  ${resp.json()['email']}                                                ${email}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      0.0
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}                                    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}                                    ${eTime1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid   ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   

    # Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    # Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    
    # Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}             ${accId}
    # Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}   ${bsname1}

    # Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}              ${jcons_id1}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}        ${jaldee_id1}

    # Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    # Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['startDate']}              ${startDate}
    # Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['terminator']['endDate']}  ${endDate}
    # Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['catalog']['catalogSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['catalog']['advanceAmount']}                             ${advanceAmount}.0

    # Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    # Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}

    # Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    # Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    # Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}.0
    # Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    # Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}.0
    # Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['startDate']}                         ${soon_date}
    # Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['terminator']['endDate']}             ${far_date}
    # Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['sTime']}             ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['orderTimeWindow']['timeSlots'][0]['eTime']}             ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}                             ${startDate}
    # Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime0}
    # Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime0}

    # Should Be Equal As Strings  ${resp.json()['isAsap']}                    ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['isFirstOrder']}              ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['coupons']}                   []
    # Should Be Equal As Strings  ${resp.json()['orderMode']}                 ${order_mode[1]}    
    # Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME19}
    # Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    # Should Be Equal As Strings  ${resp.json()['advanceAmountPaid']}         0.0
    # Should Be Equal As Strings  ${resp.json()['advanceAmountToPay']}        ${advanceAmount}.0
    # Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}           0.0
    # Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    # Should Be Equal As Strings  ${resp.json()['deliveryCharge']}            ${deliveryCharge}
    # # Should Be Equal As Strings  ${resp.json()['accesScope']}                ${sch_id}
    # # Should Be Equal As Strings  ${resp.json()['account']}                   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['onlineRequest']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['kioskRequest']}              ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['firstCheckIn']}              ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['active']}                    ${bool[0]} 


JD-TC-GetOrderById-UH1
    [Documentation]    Get an order details with invalid id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid      00a0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${ORDER_NOT_FOUND}"  

JD-TC-GetOrderById-UH2
    [Documentation]    Get an order details without login.

    ${resp}=   Get Order by uid      ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419


JD-TC-GetOrderById-UH3
    [Documentation]    Get an order details with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid      ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"  


JD-TC-GetOrderById-UH4
    [Documentation]    Get an order details with another provider order id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"  


# JD-TC-GetOrderById-UH5
#     [Documentation]    Get an order details with invalid account id.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Order by uid    00b0    ${orderid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    422



   