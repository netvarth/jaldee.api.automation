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
@{item_num}    0  1  2


*** Test Cases ***

JD-TC-UpdateOrderItems-1
    [Documentation]    update an order By provider for home delivery(updating address,email,item quantity)
    
    clear_queue    ${PUSERNAME94}
    clear_service  ${PUSERNAME94}
    clear_customer   ${PUSERNAME94}
    clear_Item   ${PUSERNAME94}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${accId}=  get_acc_id  ${PUSERNAME94}
    Set Suite Variable  ${accId} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME94}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${itemName2}=   FakerLibrary.name  
    ${itemCode2}=   FakerLibrary.word 
    ${displayName2}=   FakerLibrary.name
    Set Suite Variable   ${displayName2}
    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime2}=  add_timezone_time  ${tz}  2  35 
    Set Suite Variable   ${sTime2}
    ${eTime3}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime3}
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable    ${deliveryCharge}

 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=10   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName1}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName1} 

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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=   Create Dictionary  itemId=${item_id1}   
    ${item2}=  Create Dictionary  itemId=${item_id2}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem2}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}

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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email0}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email0}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email0}
    
    sleep  1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid1}  ${item_id1}   ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email0}
    

    ${DAY2}=  db.add_timezone_date  ${tz}  11  
    # ${address1}=  get_address
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address1}

    ${firstname2}=  FakerLibrary.first_name
    Set Suite Variable  ${email1}  ${firstname2}${CUSERNAME21}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid1}    ${bool[1]}    ${address1}    ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME21}   ${email1}  ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY2}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email1}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname1}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY2}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email1}
    
JD-TC-UpdateOrderItems-2
    [Documentation]    update an order By provider for today.
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

   
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-3
    [Documentation]   Place an order By Consumer for two items and provider update it to one items
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    ${totalprice1}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice1}=  Convert To Number  ${totalprice1}  1

    ${total}=   Evaluate   ${totalprice} + ${totalprice1}
    ${cartAmount}=  Evaluate   ${total} + ${deliveryCharge}

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['totalPrice']}   ${totalprice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}


    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${cartAmount}=  Evaluate   ${totalprice} + ${deliveryCharge}

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-4
    [Documentation]   Place an order By Consumer for one items and provider update it to two items
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_quantity2}  ${storecomment}  ${item_id2}  ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    ${totalprice1}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice1}=  Convert To Number  ${totalprice1}  1

    ${total}=   Evaluate   ${totalprice} + ${totalprice1}
    ${cartAmount}=  Evaluate   ${total} + ${deliveryCharge}

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}

    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['totalPrice']}   ${totalprice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['storeComment']}   ${storecomment}

    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${cartAmount}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-5
    [Documentation]     place an order By Consumer for Home Delivery and update it with item quantity less than that of minimum quantity in catalog.
    
    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=1   max=9
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}

    # Should Be Equal As Strings  "${resp.json()}"        "${MIN_QUANTITY_REQUIRED}"
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

   
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-6
    [Documentation]       Place an order By Consumer for Home Delivery and update it with item quantity greater than that of maximum quantity in catalog.
    
    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=${maxQuantity}   max=1000
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"        "${MAX_QUANTITY_EXCEEDS}"
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1


    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME21}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-7
    [Documentation]    place an order by consumer and update without item quantity
    
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME4}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME4}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id1}   ${item_num[0]}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"        "${MIN_QUANTITY_REQUIRED}"
   
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   0.0
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME4}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}


JD-TC-UpdateOrderItems-UH1
    [Documentation]    update an order By provider.updating with invalid orderid
    
    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery     ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   00ab  ${item_id1}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${ORDER_NOT_EXIST}"  

# JD-TC-UpdateOrderItems-UH2
#     [Documentation]    update an order By provider.updating with a item not in catalog
    
#     ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${DAY1}=  db.add_timezone_date  ${tz}  12  
#     ${address}=  get_address
#     ${delta}=  FakerLibrary.Random Int  min=10  max=90
#     ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${firstname}=  FakerLibrary.first_name
#     Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

#     ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings   ${resp.status_code}    200

#     ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${orderid}  ${orderid[0]}

#     ${resp}=   Get Order By Id    ${accId}  ${orderid}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${storecomment}=   FakerLibrary.word 
#     ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id3}   ${item_quantity2}  ${storecomment} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    422
#     Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"  


JD-TC-UpdateOrderItems-UH3
    [Documentation]    place an order by consumer  and update with disable order settings by provider.

    clear_queue    ${PUSERNAME115}
    clear_service  ${PUSERNAME115}
    clear_customer   ${PUSERNAME115}
    clear_Item   ${PUSERNAME115}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid0}  ${decrypted_data['id']}
    # Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME115}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME199}.${test_mail}

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

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    ${eTime0}=  add_timezone_time  ${tz}  3  30     
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
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
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}   ${self}   ${CatalogId}   ${bool[1]}    ${address}   ${sTime0}   ${eTime0}  ${DAY1}  ${CUSERNAME20}  ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()} 
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}

    ${item_quantity2}=  FakerLibrary.Random Int  min=${maxQuantity}   max=1000
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id0}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"       "${ORDER_SETTINGS_NOT_ENABLED}"

    ${resp}=   Get Order by uid     ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}             ${item_id0}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}       ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}

JD-TC-UpdateOrderItems-UH4
    [Documentation]   place an order by consumer and update it without item.
    
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
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
    Set Suite Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME4}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME4}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${EMPTY}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_ITEM_ID}"


JD-TC-UpdateOrderItems-UH6
    [Documentation]    Place an order By Consumer for Home Delivery and provider update it with disabled item.
    
    clear_queue    ${PUSERNAME115}
    clear_service  ${PUSERNAME115}
    clear_customer   ${PUSERNAME115}
    clear_Item   ${PUSERNAME115}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid0}  ${decrypted_data['id']}
    # Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME115}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME199}.${test_mail}

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

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    ${eTime0}=  add_timezone_time  ${tz}  3  30     
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
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
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}    ${self}    ${CatalogId}   ${bool[1]}    ${address}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Item  ${item_id0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 

    ${INVALID_ITEM_ADDED}=   Format String  ${INVALID_ITEM_ADDED}  ${displayName1}  

    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id0}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_ITEM_ADDED}"


JD-TC-UpdateOrderItems-UH7
    [Documentation]     Place an order By Consumer for Home Delivery and provider update it with removed item.
    
    clear_queue    ${PUSERNAME115}
    clear_service  ${PUSERNAME115}
    clear_customer   ${PUSERNAME115}
    clear_Item   ${PUSERNAME115}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid0}  ${decrypted_data['id']}
    # Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME115}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME199}.${test_mail}

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

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    ${eTime0}=  add_timezone_time  ${tz}  3  30     
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
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
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}    ${self}    ${CatalogId}   ${bool[1]}    ${address}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Single Item From Catalog    ${CatalogId}    ${item_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${storecomment}=   FakerLibrary.word 

    ${INVALID_ITEM_ADDED}=   Format String  ${INVALID_ITEM_ADDED}  ${displayName1}  

    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id0}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_ITEM_ADDED}"

#store pickup
  
   
JD-TC-UpdateOrderItems-8
    [Documentation]    update an order By Consumer for pickup.
    
    clear_queue    ${PUSERNAME115}
    clear_service  ${PUSERNAME115}
    clear_customer   ${PUSERNAME115}
    clear_Item   ${PUSERNAME115}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME115}
    Set Suite Variable  ${accId1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME115}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName2}=   FakerLibrary.name 
    Set Suite Variable  ${displayName2}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price1}
    Set Suite Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id0}  ${resp.json()}

    ${itemCode4}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz1}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz1}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz1}
    ${endDate1}=  db.add_timezone_date  ${tz1}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz1}  0  15  
    Set Suite Variable  ${sTime0}
    ${eTime0}=  add_timezone_time  ${tz1}  2  30   
    Set Suite Variable  ${eTime0}  
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime4}=  add_timezone_time  ${tz1}  2  35
    Set Suite Variable  ${sTime4}
    ${eTime4}=  add_timezone_time  ${tz1}  3  30   
    Set Suite Variable  ${eTime4}  
  
    ${deliveryCharge1}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge1}  
  
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity1}=  Random Int  min=1   max=30
    Set Suite Variable  ${minQuantity1}

    ${maxQuantity1}=  Random Int  min=${minQuantity1}   max=50
    Set Suite Variable  ${maxQuantity1}

    ${catalogName2}=   FakerLibrary.name  
    Set Suite Variable  ${catalogName2}

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime0}   eTime=${eTime0}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge1}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${item1_Id4}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem4}=  Create Dictionary  item=${item1_Id4}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem4}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz1}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}.${test_mail}

    ${resp}=   Create Order For Pickup     ${cookie}  ${accId1}   ${self}   ${CatalogId2}   ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERNAME2}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId1}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid2}  ${item_id0}   ${item_quantity2}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName2}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}    ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime0}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime0}


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}

JD-TC-UpdateOrderItems-9
    [Documentation]   Place an order By Consumer for two items and provider update it to one items
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId1}    ${self}    ${CatalogId2}     ${bool[1]}  ${sTime0}    ${eTime0}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    ${totalprice1}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice1}=  Convert To Number  ${totalprice1}  1

    ${total}=   Evaluate   ${totalprice} + ${totalprice1}
    
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['name']}         ${displayName4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['totalPrice']}   ${totalprice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${total}

    sleep  1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id0}   ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    # ${cartAmount}=  Evaluate   ${totalprice} + ${deliveryCharge}

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName2}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrderItems-10
    [Documentation]   Place an order By Consumer for one items and provider update it to two items
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME5}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId1}    ${self}    ${CatalogId2}     ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY}    ${CUSERNAME5}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    
    sleep  1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id0}   ${item_quantity2}  ${storecomment}  ${item_id4}  ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    ${totalprice1}=   Evaluate  ${item_quantity2} * ${promoPrice2}
    ${totalprice1}=  Convert To Number  ${totalprice1}  1

    ${total}=   Evaluate   ${totalprice} + ${totalprice1}
    ${cartAmount}=  Evaluate   ${total} + ${deliveryCharge1}

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName2}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['storeComment']}   ${storecomment}

    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['name']}         ${displayName4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['totalPrice']}   ${totalprice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['storeComment']}   ${storecomment}

    Should Be Equal As Strings  ${resp.json()['cartAmount']}                ${total}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

#provider side
JD-TC-UpdateOrderItems-11
    [Documentation]     Create order by provider for Home Delivery when payment type is NONE (No Advancepayment) and update order

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME189}
    clear_service  ${PUSERNAME189}
    clear_customer   ${PUSERNAME189}
    clear_Item   ${PUSERNAME189}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME189}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME189}.${test_mail}

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
    
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Suite Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice3}=  Random Int  min=10   max=${price2} 
    ${promoPrice3}=  Convert To Number  ${promoPrice3}  1
    Set Suite Variable  ${promoPrice3}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice3}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${promoLabel1}=   FakerLibrary.word 

    ${itemCode3}=   FakerLibrary.word 
    ${itemName3}=   FakerLibrary.name  
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}
    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item2_id3}  ${resp.json()}

    ${itemCode4}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item2_id4}  ${resp.json()}

    ${itemCode5}=   FakerLibrary.word 
    ${itemName5}=   FakerLibrary.name  
    ${displayName5}=   FakerLibrary.name 
    Set Suite Variable  ${displayName5}
    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item2_id5}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz3}
    ${endDate}=  db.add_timezone_date  ${tz3}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz3}
    ${endDate1}=  db.add_timezone_date  ${tz3}  15    

    ${startDate2}=  db.add_timezone_date  ${tz3}  5  
    ${endDate2}=  db.add_timezone_date  ${tz3}  25      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime4}=  add_timezone_time  ${tz3}  0  15  
    Set Suite Variable   ${sTime4}
    ${eTime4}=  add_timezone_time  ${tz3}  1  00   
    Set Suite Variable    ${eTime4}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime5}=  add_timezone_time  ${tz3}  1  15  
    Set Suite Variable   ${sTime5}
    ${eTime5}=  add_timezone_time  ${tz3}  2  00   
    Set Suite Variable    ${eTime5}
  
    ${deliveryCharge1}=  Random Int  min=50   max=100
    Set Suite Variable    ${deliveryCharge1}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge1}  1
    Set Suite Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}


    ${catalogDesc}=   FakerLibrary.name 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime5}   eTime=${eTime5}

    ${timeSlots}=  Create List  ${timeSlots1}  ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}

    ${terminator2}=  Create Dictionary  endDate=${endDate2}  noOfOccurance=${noOfOccurance}
    ${pickupSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate2}   terminator=${terminator2}   timeSlots=${timeSlots}
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule2}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList2}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList2} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item2_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item2_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Test Variable  ${catalogItem}
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    Set Test Variable  ${paymentType2}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14

    ${soon}=  Random Int  min=0   max=0

    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName3}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${catalogName4}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${catalogName5}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200


    # ${cid20}=  get_id  ${CUSERNAME20}
    # Set Suite Variable   ${cid20}
    ${DAY1}=  db.add_timezone_date  ${tz3}  12  
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
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME189}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}  ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item2_id3}   ${item_quantity1}  ${item2_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid3}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
 
    sleep   1s
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid3}  ${item2_id3}   ${item_quantity2}  ${storecomment}  ${item2_id4}  ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalprice}=   Evaluate  ${item_quantity2} * ${promoPrice3}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid     ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid3}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName3}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName3}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice3}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

JD-TC-UpdateOrderItems-UH8
    [Documentation]    update order with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid3}  ${item2_id3}   ${item_quantity2}  ${storecomment}  ${item2_id4}  ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-UpdateOrderItems-UH9
    [Documentation]    update order without login
  
    ${DAY1}=  db.add_timezone_date  ${tz3}   8
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid3}  ${item2_id3}   ${item_quantity2}  ${storecomment}  ${item2_id4}  ${item_quantity2}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 
***comment***

JD-TC-UpdateDeliveryCharge-12
    [Documentation]  same consumer place an oder for both pick up and home delivery when Advanced_payment_type is Full_Amount

    clear_queue    ${PUSERNAME101}
    clear_service  ${PUSERNAME101}
    clear_customer   ${PUSERNAME101}
    clear_Item   ${PUSERNAME101}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId11}=  get_acc_id  ${PUSERNAME101}
    Set Suite Variable  ${accId11}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id2}  ${firstname}${PUSERNAME101}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid2}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME101}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid2}  ${merchantid}


    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName11}=   FakerLibrary.name 
    Set Suite Variable  ${displayName11}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price11}=  Random Int  min=50   max=300
    ${price11}=  Convert To Number  ${price11}  1
    Set Suite Variable  ${price11}


    ${price1float}=  twodigitfloat  ${price11}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice11}=  Random Int  min=10   max=${price11} 
    ${promoPrice11}=  Convert To Number  ${promoPrice11}  1
    Set Suite Variable  ${promoPrice11}


    ${promoPrice2float}=  twodigitfloat  ${promoPrice11}

    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName11}    ${shortDesc1}    ${itemDesc1}    ${price11}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice11}   ${promotionalPrcnt2}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

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
  
    ${deliveryCharge2}=  Random Int  min=50   max=100
 
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

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}    ${catalogStatus[0]}
    Set Test Variable  ${paymentType3}     ${AdvancedPaymentType[2]}
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType3}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}    showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId11}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY11}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${DAY11}
    # ${address}=  get_address
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
    Set Test Variable  ${address}
      
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    ${item_quantity2}=  Convert To Number  ${item_quantity2}  1

    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}

    ${resp}=   Create Order For HomeDelivery  ${cookie}   ${accId11}    ${self}    ${CatalogId11}   ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY11}    ${CUSERNAME10}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid11}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId11}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY12}=  db.add_timezone_date  ${tz}   14
    ${address}=  get_address
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId11}    ${self}    ${CatalogId11}   ${bool[1]}   ${sTime2}    ${eTime2}   ${DAY12}    ${CUSERNAME10}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id2}    ${item_quantity2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId11}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid11} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${EMPTY}

    ${resp}=   Get Order by uid    ${orderid12} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${EMPTY} 

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id    ${accId11}   ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item_one}=  Evaluate  ${item_quantity2} * ${promoPrice11}
    ${item_one}=  Convert To Number  ${item_one}  1
    Set Suite Variable   ${item_one}  


    ${deliveryCharge2}=  Convert To Number  ${deliveryCharge2}  1
    Set Suite Variable   ${deliveryCharge2}   ${deliveryCharge2}
    
    ${totalTaxAmount}=  Evaluate  ${item_one} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${item_one} + ${totalTaxAmount} + ${deliveryCharge2}
    Set Suite Variable   ${amountDue}


    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid10}=  get_id  ${CUSERNAME10}
    Set Suite Variable   ${cid10}

    ${resp}=  Make payment Consumer Mock  ${amountDue}  ${bool[1]}  ${orderid11}  ${accId11}  ${purpose[0]}  ${cid10}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid11}  ${accId11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${amountDue}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${amountDue}  amountDue=0.0    totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge2}

    ${resp}=   Get Order By Id   ${accId11}  ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}        ${orderid11}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id4}  ${resp.json()[0]['id']}

    ${resp}=   Get Order by uid    ${orderid11} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}        ${orderid11}

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}   netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${amountDue}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${amountDue}  amountDue=0.0    totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge2}  netRate=${amountDue}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${item_one} 
   
    ${item_quantity22}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    ${storecomment}=   FakerLibrary.word 
    ${resp}=   Update Order Items By Provider   ${orderid11}  ${item_id2}   ${item_quantity22}  ${storecomment} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${total0}=  Evaluate  ${item_one} + ${totalTaxAmount} 
    # Set Suite Variable   ${total0} 
    # ${total1}=  Evaluate   ${total0} + ${deliveryCharge_1} 
    
    # ${refund}=  Evaluate  ${deliveryCharge_1} - ${deliveryCharge2}

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${total1}  billPaymentStatus=${paymentStatus[3]}  totalAmountPaid=${amountDue}  amountDue=${refund}   totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge_1}  netRate=${total1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${item_one} 
   
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId11}  ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid11}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY11}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${item_one}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total1}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                            ${paymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                              ${deliveryCharge_1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            ${refund}



   