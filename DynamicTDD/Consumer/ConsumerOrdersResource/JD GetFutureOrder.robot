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

JD-TC-GetFutureOrderByCriteria-1
    [Documentation]    Get an order details by order id.

    clear_queue    ${PUSERNAME164}
    clear_service  ${PUSERNAME164}
    clear_customer   ${PUSERNAME164}
    clear_Item   ${PUSERNAME164}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME164}
    Set Suite Variable  ${accId} 

    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME164}.ynwtest@netvarth.com

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

    ${startDate}=  db.subtract_timezone_date  ${tz}    5
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
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

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

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
   
    ${far}=  Random Int  min=5  max=5
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${catalogName1}=   FakerLibrary.name  

    ${far1}=  Random Int  min=14  max=14 
    ${soon1}=  Random Int  min=1   max=1

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far1}   howSoon=${soon1}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME25}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME25}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no1}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jcons_id1}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME25}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${fname1}=  FakerLibrary.first_name
    Set Suite Variable   ${fname1}
    ${lname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lname1}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember  ${fname1}  ${lname1}  ${dob}  ${gender}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId}    ${mem_id}    ${CatalogId1}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME25}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no2}  ${resp.json()['orderNumber']}

    ${DAY2}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable   ${DAY2}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId2}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME25}    ${email}   ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no3}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jcons_id2}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=   Get Future Order  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3}  
  
JD-TC-GetFutureOrderByCriteria-2
    [Documentation]    Get an order details by account id.

    clear_queue    ${PUSERNAME135}
    clear_service  ${PUSERNAME135}
    clear_customer   ${PUSERNAME135}
    clear_Item   ${PUSERNAME135}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME135}
    Set Test Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME135}.ynwtest@netvarth.com

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
    
    ${itemName2}=   FakerLibrary.name  
    ${displayName2}=   FakerLibrary.name 
    ${itemCode2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id2}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  15       

    ${startDate1}=  db.get_date_by_timezone  ${tz}
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

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=1   max=1
   
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

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME25}.ynwtest@netvarth.com

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId1}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME25}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId1}  ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no4}  ${resp.json()['orderNumber']}

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId1}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME25}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid5}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId1}  ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no5}  ${resp.json()['orderNumber']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   account-eq=${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    
    ${resp}=   Get Future Order   account-eq=${accId1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 
    Verify Response List    ${resp}  1    uid=${orderid5} 

JD-TC-GetFutureOrderByCriteria-3
    [Documentation]    Get an order details by home delivery = true.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   homeDelivery-eq=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 
    Verify Response List    ${resp}  1    uid=${orderid5} 
    
JD-TC-GetFutureOrderByCriteria-4
    [Documentation]    Get an order details by pickup = true.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   storePickup-eq=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 

JD-TC-GetFutureOrderByCriteria-5
    [Documentation]    Get an order details by pickup = false.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   storePickup-eq=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 
    Verify Response List    ${resp}  1    uid=${orderid5} 

JD-TC-GetFutureOrderByCriteria-6
    [Documentation]    Get an order details by order status received.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderStatus-eq=${orderStatuses[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    Verify Response List    ${resp}  1    uid=${orderid4} 
    Verify Response List    ${resp}  2    uid=${orderid5} 

JD-TC-GetFutureOrderByCriteria-7
    [Documentation]    Get an order details by order status confirmed.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderStatus-eq=${orderStatuses[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-8
    [Documentation]    Get an order details by order date.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderDate-eq=${DAY2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    Verify Response List    ${resp}  1    uid=${orderid4}
    Verify Response List    ${resp}  2    uid=${orderid5}  

JD-TC-GetFutureOrderByCriteria-9
    [Documentation]    Get an order details by future order date.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Future Order   orderDate-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    
    Should Be Equal As Strings  "${resp.json()}"    "${INCORRECT_DATE}"

JD-TC-GetFutureOrderByCriteria-10
    [Documentation]    Get an order details by order number.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderNumber-eq=${order_no3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 

    ${resp}=   Get Future Order   orderNumber-eq=${order_no4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 

    ${resp}=   Get Future Order   orderNumber-eq=${order_no5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid5} 
    
JD-TC-GetFutureOrderByCriteria-11
    [Documentation]    Get future order details by order number.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderNumber-eq=${order_no1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

    ${resp}=   Get Future Order   orderNumber-eq=${order_no2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-12
    [Documentation]    Get an order details by order mode (online order).

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderMode-eq=${order_mode[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    Verify Response List    ${resp}  1    uid=${orderid4}
    Verify Response List    ${resp}  2    uid=${orderid5}  

JD-TC-GetFutureOrderByCriteria-13
    [Documentation]    Get an order details by order mode(walkin order).

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderMode-eq=${order_mode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-14
    [Documentation]    Get an order details by order mode(phone order).

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   orderMode-eq=${order_mode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-15
    [Documentation]    Get an order details by first name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   firstName-eq=${fname}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    
JD-TC-GetFutureOrderByCriteria-16
    [Documentation]    Get an order details by last name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   lastName-eq=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    
JD-TC-GetFutureOrderByCriteria-17
    [Documentation]    Get an order details by email id.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   email-eq=${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
   
JD-TC-GetFutureOrderByCriteria-18
    [Documentation]    Get an order details by phone number.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   phoneNumber-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
    Verify Response List    ${resp}  1    uid=${orderid4}
    Verify Response List    ${resp}  2    uid=${orderid5}

JD-TC-GetFutureOrderByCriteria-19
    [Documentation]    Get an order details by jaldee id.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   jaldeeId-eq=${jcons_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid3} 
 
JD-TC-GetFutureOrderByCriteria-20
    [Documentation]    Get an order details by family member's last name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

    # Verify Response List    ${resp}  0    uid=${orderid2} 
  
JD-TC-GetFutureOrderByCriteria-21
    [Documentation]    Get an order details by family member's first name.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

    # Verify Response List    ${resp}  0    uid=${orderid2} 

JD-TC-GetFutureOrderByCriteria-22
    [Documentation]    Get an order details by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-23
    [Documentation]    Get an order details by invalid account id.

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Future Order   account-eq=000
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetFutureOrderByCriteria-UH1
    [Documentation]    Get an order details without login.

    ${resp}=   Get Future Order   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  
