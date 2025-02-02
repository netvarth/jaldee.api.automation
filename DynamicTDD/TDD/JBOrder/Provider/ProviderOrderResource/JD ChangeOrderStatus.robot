
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

*** Test Cases ***

JD-TC-Changeorderstatus-1
    [Documentation]  Change order status to preparing from order recived 
    
    clear_queue    ${PUSERNAME106}
    clear_service  ${PUSERNAME106}
    clear_customer   ${PUSERNAME106}
    clear_Item   ${PUSERNAME106}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME106}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME106}.${test_mail}

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

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}   ${orderStatuses[4]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[8]}   ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}  
    Set Suite Variable   ${StatusList}

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

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}  max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME2}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId1}   ${orderid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[0]}
    
    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  02s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}


JD-TC-Changeorderstatus-2
    [Documentation]  Change order status to packing from order recived 
    
    clear_queue    ${PUSERNAME107}
    clear_service  ${PUSERNAME107}
    clear_customer   ${PUSERNAME107}
    clear_Item   ${PUSERNAME107}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid2}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME107}
    Set Suite Variable  ${accId2} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME107}.${test_mail}

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
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime0}
    ${eTime0}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime0}
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

    ${timeSlots1}=  Create Dictionary  sTime=${sTime0}   eTime=${eTime0}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable   ${StatusList1}
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=  Create Dictionary  itemId=${item_id2}    
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


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}  max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME11}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId2}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERNAME11}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId2}   ${orderid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}       ${StatusList1[0]}
    
    ${resp}=  Change Order Status   ${orderid2}   ${StatusList1[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Get Order Status Changes by uid    ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList1[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList1[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    
JD-TC-Changeorderstatus-3
    [Documentation]  change status to ready for delivery from Preparing
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

JD-TC-Changeorderstatus-4
    [Documentation]  change status to ready for shipment from ready for delivery
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

    
    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}

    
JD-TC-Changeorderstatus-5
    [Documentation]  change status to completed from ready for delivery
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}

    
    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList[9]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}



JD-TC-Changeorderstatus-6
    [Documentation]  change status to shipped from completed
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList[9]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}

    
    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[11]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList[9]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${StatusList[11]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}

    

JD-TC-Changeorderstatus-7
    [Documentation]  change status to canceld from shipped
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList[9]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${StatusList[11]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}

    
    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList[8]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList[7]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList[9]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${StatusList[11]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${StatusList[12]}
    # Should Be Equal As Strings  ${resp.json()[2]['time']}                ${startDate}


JD-TC-Changeorderstatus-8
    [Documentation]  Change order status to preparing from order recived 
    
    clear_queue    ${PUSERNAME108}
    clear_service  ${PUSERNAME108}
    clear_customer   ${PUSERNAME108}
    clear_Item   ${PUSERNAME108}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid3}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid3}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME108}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME108}.${test_mail}

    ${resp}=  Update Email   ${pid3}   ${firstname}   ${lastname}   ${email_id}
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
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime2}
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

    ${StatusList3}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable   ${StatusList3}

    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=  Create Dictionary  itemId=${item_id3}    
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
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME6}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId3}    ${bool[1]}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME6}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId3}   ${orderid3}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}     ${StatusList3[0]}
    
    ${resp}=  Change Order Status   ${orderid3}   ${StatusList3[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

JD-TC-Changeorderstatus-9
    [Documentation]  change status to ready for pickup from order confermed 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}


    ${resp}=  Change Order Status   ${orderid3}   ${StatusList3[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList3[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

    
JD-TC-Changeorderstatus-10
    [Documentation]  change status to  completed from ready to pickup 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList3[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}


    ${resp}=  Change Order Status   ${orderid3}   ${StatusList3[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList3[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList3[6]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}

    
JD-TC-Changeorderstatus-11
    [Documentation]  change status to  cancelled from completed 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList3[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList3[6]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}


    ${resp}=  Change Order Status   ${orderid3}   ${StatusList3[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList3[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}              ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList3[2]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${StatusList3[4]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${StatusList3[6]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${StatusList3[9]}
    # Should Be Equal As Strings  ${resp.json()[1]['time']}                ${startDate}


JD-TC-Changeorderstatus-UH1
    [Documentation]  change status when status not in status list

    ${resp}=  Encrypted Provider Login   ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Order Status   ${orderid2}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_ACTION}"

JD-TC-Changeorderstatus-UH2
    [Documentation]  Change order status of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME106}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Order Status   ${orderid2}   ${StatusList1[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-Changeorderstatus-UH3
    [Documentation]  Change order status without login

    ${resp}=  Change Order Status   ${orderid2}   ${StatusList1[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Changeorderstatus-UH4
    [Documentation]  Change order status of invalid orderid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Order Status   00rv0   ${StatusList1[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ORDER_NOT_FOUND}"


