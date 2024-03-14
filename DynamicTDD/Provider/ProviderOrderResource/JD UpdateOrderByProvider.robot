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
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***

JD-TC-UpdateOrder-1
    [Documentation]    update an order By provider for home delivery(updating address,email,item quantity)
    
    clear_queue    ${PUSERNAME100}
    clear_service  ${PUSERNAME100}
    # clear_customer   ${PUSERNAME100}
    clear_Item   ${PUSERNAME100}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${accId}=  get_acc_id  ${PUSERNAME100}
    Set Suite Variable  ${accId} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME100}.${test_mail}

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

    ${sTime3}=  add_timezone_time  ${tz}  2  40
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable  ${eTime3}  
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

    ${catalogName1}=   FakerLibrary.first_name 
    Set Suite Variable  ${catalogName1} 

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}  ${timeSlots2}
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
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
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
    
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+154687
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH0}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
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
    Set Test Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email0}  ${firstname}${CUSERPH0}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH0}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH0}    ${email0}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH0}
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
    
    sleep  1s
    ${firstname2}=  FakerLibrary.first_name
    Set Suite Variable  ${email1}  ${firstname2}${CUSERPH0}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid1}    ${bool[1]}    ${address1}    ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERPH0}   ${email1}  ${countryCodes[1]}  
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
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY2}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH0}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email1}
    
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
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH0}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email1}
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH0}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email1}
    

JD-TC-UpdateOrder-2
    [Documentation]    update an order By provider for today.
    

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+154688
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

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
    
    sleep  1s
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}   ${address1}   ${sTime1}   ${eTime1}   ${DAY}  ${CUSERNAME6}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
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

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}             ${orderid}

JD-TC-UpdateOrder-3
    [Documentation]    update an order By Consumer for Home Delivery without phonenumber
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

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
    
    sleep  1s
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}   ${address1}   ${sTime1}   ${eTime1}   ${DAY}  ${EMPTY}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH1}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}


JD-TC-UpdateOrder-4
    [Documentation]    update an order By Consumer for Home Delivery without email
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

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
    
    sleep  1s
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}   ${address1}   ${sTime1}   ${eTime1}   ${DAY}  ${CUSERPH1}  ${EMPTY}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
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

    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH1}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    

JD-TC-UpdateOrder-5
    [Documentation]   update an homdelivery order to pickup
    

    ${CUSERPH2}=  Evaluate  ${CUSERPH}+154689
    Set Suite Variable   ${CUSERPH2}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH2}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    
    sleep  1s
    ${DAY1}=  db.add_timezone_date  ${tz}  11  
    # ${address1}=  get_address
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH0}.${test_mail}
    ${resp}=   Update Order For Pickup   ${orderid}    ${bool[1]}   ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH2}   ${email2}  ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName1}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH2}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email2}
    

JD-TC-UpdateOrder-6
    [Documentation]    Update a family member's order.

    clear_queue    ${PUSERNAME111}
    clear_service  ${PUSERNAME111}
    # clear_customer   ${PUSERNAME111}
    clear_Item   ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME111}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME111}.${test_mail}

    ${resp}=  Update Email   ${pid0}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName}=   FakerLibrary.name 
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

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
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
    

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+154685
    Set Suite Variable   ${CUSERPH3}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH3}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}


    ${fname0}=  FakerLibrary.first_name
    ${lname0}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember  ${fname}  ${lname}  ${dob}  ${gender}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH3}.${test_mail}

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}  ${mem_id}  ${CatalogId}  ${bool[1]}   ${address}  ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    
    sleep  1s
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid2}   ${bool[1]}    ${address1}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
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
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName}
    # Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname0}
    # Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname0}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice1}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH3}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email2}
    

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId0}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}              ${orderid2}

JD-TC-UpdateOrder-UH1
    [Documentation]    update an order By Consumer for Home Delivery a date other than in catalog schedule.
    
    clear_queue    ${PUSERNAME111}
    clear_service  ${PUSERNAME111}
    # clear_customer   ${PUSERNAME111}
    clear_Item   ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME111}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME111}.${test_mail}

    ${resp}=  Update Email   ${pid0}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName}=   FakerLibrary.name 
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

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
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

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH3}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}  ${self}  ${CatalogId}  ${bool[1]}   ${address}  ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
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
 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address1}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${DELIVERY_DATE_NOT_SUPPORTED}"

JD-TC-UpdateOrder-UH2
    [Documentation]    update an order By provider. update order by using another provider orderid
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}  ${self}  ${CatalogId1}  ${bool[1]}   ${address}  ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERPH2}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For HomeDelivery   ${orderid2}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERPH2}  ${email}  ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    # Should Be Equal As Strings  "${resp.json()}"   "${ORDER_NOT_EXIST}"  
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"  


JD-TC-UpdateOrder-UH3
    [Documentation]    update an order By Consumer for Home Delivery without home delivery address.
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
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
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}   ${self}    ${CatalogId1}    ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    # ${address1}=  get_address
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${EMPTY}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY}  ${CUSERPH1}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${PROVIDE_ADDRESS}"  
 
JD-TC-UpdateOrder-UH4
    [Documentation]    update an order By provider.(update with a far date)
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}   17
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateOrder-UH5
    [Documentation]   update an order by provider for a past date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.subtract_timezone_date  ${tz}    2
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_IS_PAST}"
  
JD-TC-UpdateOrder-UH6
    [Documentation]   update an order by provider  without an order date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${EMPTY}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_NEEDED}"
  
JD-TC-UpdateOrder-UH7
    [Documentation]   update an order by provider homdelivery  with delivery address is false.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[0]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${DELIVERY_INPUT_NEEDED}"
  
JD-TC-UpdateOrder-UH8
    [Documentation]    place an order by consumer  and update with disable order settings by provider.

    clear_queue    ${PUSERNAME111}
    clear_service  ${PUSERNAME111}
    # clear_customer   ${PUSERNAME111}
    clear_Item   ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME111}

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

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH0}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId0}   ${self}   ${CatalogId}   ${bool[1]}    ${address}   ${sTime0}   ${eTime0}  ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()} 
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
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

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}   ${address}    ${sTime0}    ${eTime0}   ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"       "${ORDER_SETTINGS_NOT_ENABLED}"

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}

JD-TC-UpdateOrder-UH9
    [Documentation]   update an order by provider after provider change order status to cancel.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid}   ${StatusList[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

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

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address1}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${CANT_UPDATE_CANCELLED_ORDER}"
  
    
    # ${resp}=   Get Order by uid    ${orderid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-UpdateOrder-UH10
    [Documentation]   update an order by provider after consumer cancel the order.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}  ${self}    ${CatalogId1}  ${bool[1]}   ${address}   ${sTime1}   ${eTime1}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Cancel Order By Consumer    ${accId}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  04s
    ${resp}=   Get Order By Id    ${accId}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Change Order Status   ${orderid}   ${StatusList[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Order Status Changes by uid    ${orderid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

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

    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address1}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${CANT_UPDATE_CANCELLED_ORDER}"
  
    
    # ${resp}=   Get Order by uid    ${orderid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

#store pickup

JD-TC-UpdateOrder-7
    [Documentation]    update an order By Consumer for pickup.
    
    clear_queue    ${PUSERNAME112}
    clear_service  ${PUSERNAME112}
    # clear_customer   ${PUSERNAME112}
    clear_Item   ${PUSERNAME112}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME112}
    Set Suite Variable  ${accId1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME112}.${test_mail}

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

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id0}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime0}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable  ${sTime0}
    ${eTime0}=  add_timezone_time  ${tz}  2  30   
    Set Suite Variable  ${eTime0}  
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime2}=  add_timezone_time  ${tz}  2  35
    Set Suite Variable  ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable  ${eTime2}  
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity1}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity1}

    ${maxQuantity1}=  Random Int  min=${minQuantity1}   max=50
    Set Suite Variable   ${maxQuantity1}

    ${catalogName2}=   FakerLibrary.name  
    Set Suite Variable  ${catalogName2}

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime0}   eTime=${eTime0}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
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
    
    ${CUSERPH4}=  Evaluate  ${CUSERPH}+154684
    Set Suite Variable   ${CUSERPH4}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH4}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH4}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH4}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH4}.${test_mail}

    ${resp}=   Create Order For Pickup     ${cookie}  ${accId1}   ${self}   ${CatalogId2}   ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH4}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId1}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${DAY2}=  db.add_timezone_date  ${tz}  13  
    ${resp}=   Update Order For Pickup   ${orderid2}   ${bool[1]}   ${sTime2}    ${eTime2}   ${DAY2}    ${CUSERPH4}    ${email}   ${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
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
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY2}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH4}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}       ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime2}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime2}


    ${resp}=  Consumer Login  ${CUSERPH4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}

JD-TC-UpdateOrder-8
    [Documentation]    update an pickup order By provider for today.
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=    Create Order For Pickup    ${cookie}  ${accId1}    ${self}    ${CatalogId2}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    
    sleep  1s
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}  ${sTime0}   ${eTime0}   ${DAY}  ${CUSERNAME6}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
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
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

JD-TC-UpdateOrder-9
    [Documentation]    update an pickuporder to homdelivery.
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=    Create Order For Pickup    ${cookie}  ${accId1}    ${self}    ${CatalogId2}     ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY}    ${CUSERPH1}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${orderid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${firstname}=  FakerLibrary.first_name
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
    
    sleep   1s
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${resp}=    Update Order For HomeDelivery    ${orderid}   ${bool[1]}    ${address1}   ${sTime2}   ${eTime2}   ${DAY}  ${CUSERNAME6}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName2}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}.0
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}    ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime2}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime2}

    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid} 

JD-TC-UpdateOrder-UH11
    [Documentation]    update an order By Consumer for pickup date other than in catalog schedule.
    
    clear_queue    ${PUSERNAME118}
    clear_service  ${PUSERNAME118}
    # clear_customer   ${PUSERNAME118}
    clear_Item   ${PUSERNAME118}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME118}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME118}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME118}.${test_mail}

    ${resp}=  Update Email   ${pid0}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName}=   FakerLibrary.name 
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

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
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

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH3}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId0}  ${self}  ${CatalogId}  ${bool[1]}  ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid7}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid7}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid7}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME118}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For Pickup   ${orderid7}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${PICKUP_DATE_NOT_SUPPORTED}"

JD-TC-UpdateOrder-UH12
    [Documentation]    update an order By provider. update order by using another provider orderid
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId1}  ${self}  ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid7}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH2}  ${email}  ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"  


JD-TC-UpdateOrder-UH13
    [Documentation]    update an order By provider.(update with a far date)
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}   17
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${PICKUP_DATE_NOT_SUPPORTED}"  


JD-TC-UpdateOrder-UH14
    [Documentation]   update an order by provider for a past date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}  ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.subtract_timezone_date  ${tz}    2
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_IS_PAST}"
  
JD-TC-UpdateOrder-UH15
    [Documentation]   update an order by provider  without an order date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup  ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${EMPTY}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_NEEDED}"
  
JD-TC-UpdateOrder-UH16
    [Documentation]   update an order by provider pickup  with delivery pickup is false.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[0]}   ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PICKUP_INPUT_NEEDED}"
  
JD-TC-UpdateOrder-UH17
    [Documentation]    place an order by consumer  and update with disable order settings by provider.

    clear_queue    ${PUSERNAME111}
    clear_service  ${PUSERNAME111}
    # clear_customer   ${PUSERNAME111}
    clear_Item   ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME111}

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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
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

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH0}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId0}   ${self}   ${CatalogId}   ${bool[1]}   ${sTime0}   ${eTime0}  ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()} 
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
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

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"       "${ORDER_SETTINGS_NOT_ENABLED}"

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}

JD-TC-UpdateOrder-UH18
    [Documentation]   update an order by provider after provider change order status to cancel.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}    ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid}   ${StatusList[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

    # ${address1}=  get_address
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
    Set Suite Variable  ${address}

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${CANT_UPDATE_CANCELLED_ORDER}"
  
    
  
JD-TC-UpdateOrder-UH19
    [Documentation]   update an order by provider after consumer cancel the order.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Cancel Order By Consumer    ${accId1}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  04s
    ${resp}=   Get Order By Id    ${accId1}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Change Order Status   ${orderid}   ${StatusList[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Order Status Changes by uid    ${orderid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

    # ${address1}=  get_address
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
    Set Suite Variable  ${address}

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}     ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${CANT_UPDATE_CANCELLED_ORDER}"
  
    
   
#providerside order

JD-TC-UpdateOrder-10
    [Documentation]     Create order by provider for Home Delivery when payment type is NONE (No Advancepayment) and update order
    
    ${CUSERPH5}=  Evaluate  ${CUSERPH}+154683
    Set Suite Variable   ${CUSERPH5}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH5}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH5}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH5}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH5}${\n}


    # ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME114}
    clear_service  ${PUSERNAME114}
    # clear_customer   ${PUSERNAME114}
    clear_Item   ${PUSERNAME114}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME114}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME114}.${test_mail}

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
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Suite Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${promoLabel1}=   FakerLibrary.word 

    ${itemCode3}=   FakerLibrary.word 
    ${itemName3}=   FakerLibrary.name  
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}
    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${itemCode4}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${itemCode5}=   FakerLibrary.word 
    ${itemName5}=   FakerLibrary.name  
    ${displayName5}=   FakerLibrary.name 
    Set Suite Variable  ${displayName5}
    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15    

    ${startDate2}=  db.add_timezone_date  ${tz}  5  
    ${endDate2}=  db.add_timezone_date  ${tz}  25      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime4}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime4}
    ${eTime4}=  add_timezone_time  ${tz}  1  00   
    Set Suite Variable    ${eTime4}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime5}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime5}
    ${eTime5}=  add_timezone_time  ${tz}  1  00   
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
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
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
    Set Suite Variable  ${catalogName3}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${catalogName4}=   FakerLibrary.name  
    Set Suite Variable  ${catalogName4}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${catalogName5}=   FakerLibrary.name  
    Set Suite Variable  ${catalogName5}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERPH5}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    # ${cid20}=  get_id  ${CUSERPH0}
    # Set Suite Variable   ${cid20}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH5}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}  ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH5}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
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


    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1
    ${totalprice1}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice1}=  Convert To Number  ${totalprice1}  1

    ${total}=   Evaluate   ${totalprice} + ${totalprice1}
    

    # ${address1}=   get_address
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
    
    sleep  1s
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid3}   ${bool[1]}    ${address1}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid3}
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
 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName3}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName3}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['name']}         ${displayName4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][1]['totalPrice']}   ${totalprice1}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERPH3}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email2}
    

JD-TC-UpdateOrder-UH20
    [Documentation]    Update an order By Provider for Home delivery a date other than in catalog schedule.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId5}   ${boolean[1]}   ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH5}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${Add_Day1}=  db.add_timezone_date  ${tz}  1
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${Add_Day1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${DELIVERY_DATE_NOT_SUPPORTED}"



JD-TC-UpdateOrder-UH21
    [Documentation]   Update an order by Provider for a past date.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME4}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${Sub_DAY1}=  db.subtract_timezone_date  ${tz}    1
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${Sub_DAY1}    ${CUSERNAME4}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_IS_PAST}"
  

JD-TC-UpdateOrder-UH22
    [Documentation]   Update an order by Provider  without an order date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  11  
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME4}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For HomeDelivery   ${orderid}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${EMPTY}    ${CUSERNAME4}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_NEEDED}"

JD-TC-UpdateOrder-UH23
    [Documentation]    Update an order By Provider for Home delivery with Home_delivery as false.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  11  
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME4}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Update Order For HomeDelivery    ${orderid}   ${bool[0]}    ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${DELIVERY_INPUT_NEEDED}"


JD-TC-UpdateOrder-UH24
    [Documentation]    Update an order By Provider for Home Delivery without Home_Delivery_Address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  11  
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME4}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${EMPTY}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${resp}=   Update Order For HomeDelivery    ${orderid}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${PROVIDE_ADDRESS}"

JD-TC-UpdateOrder-UH25
    [Documentation]    update order with consumer login

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}   8
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

    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Update Order For HomeDelivery    ${orderid3}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-UpdateOrder-UH26
    [Documentation]    update order without login
  
    ${DAY1}=  db.add_timezone_date  ${tz}   8
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME4}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${resp}=   Update Order For HomeDelivery    ${orderid3}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 
#provider pickup
JD-TC-UpdateOrder-11
    [Documentation]     Create order by provider for pickup when payment type is NONE (No Advancepayment) and update order
    
    ${CUSERPH6}=  Evaluate  ${CUSERPH}+154682
    Set Suite Variable   ${CUSERPH6}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH6}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH6}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH6}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH6}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH6}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/consumernumbers.txt  ${CUSERPH6}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  AddCustomer  ${CUSERPH6}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid21}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid21}   ${cid21}   ${CatalogId3}   ${boolean[1]}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH6}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid8}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid8} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid8}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    
    ${DAY2}=  db.add_timezone_date  ${tz}  13  
    ${resp}=   Update Order For Pickup   ${orderid8}   ${bool[1]}   ${sTime4}    ${eTime4}   ${DAY2}    ${CUSERNAME3}    ${email}   ${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${resp}=   Get Order by uid    ${orderid8}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid8}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName3}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName3}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY2}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME3}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}       ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime4}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime4}


    # ${resp}=  Consumer Login  ${CUSERPH6}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Order By Id   ${accId3}  ${orderid8}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-UpdateOrder-12
    [Documentation]    update an pickuporder to homdelivery.
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  AddCustomer  ${CUSERPH1}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid22}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid22}   ${cid22}   ${CatalogId3}   ${boolean[1]}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH1}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 

    ${totalprice}=   Evaluate  ${item_quantity1} * ${promoPrice2}
    ${totalprice}=  Convert To Number  ${totalprice}  1

    ${firstname}=  FakerLibrary.first_name
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
    
    sleep  1s
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${resp}=    Update Order For HomeDelivery    ${orderid}   ${bool[1]}    ${address1}   ${sTime4}   ${eTime4}   ${DAY1}  ${CUSERNAME6}  ${email}  ${countryCodes[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}             ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}              ${lname}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}            ${catalogName3}
    Should Be Equal As Strings  ${resp.json()['orderFor']['firstName']}              ${fname}
    Should Be Equal As Strings  ${resp.json()['orderFor']['lastName']}               ${lname}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}         ${displayName3}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}     ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}        ${promoPrice2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}       FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}   ${totalprice}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}            ${StatusList[0]}
    Should Be Equal As Strings  ${resp.json()['orderDate']}              ${DAY1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}               ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['email']}                     ${email}
    Should Be Equal As Strings  ${resp.json()['lastStatusUpdatedDate']}    ${startDate}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['sTime']}        ${sTime4}
    Should Be Equal As Strings  ${resp.json()['timeSlot']['eTime']}        ${eTime4}


JD-TC-UpdateOrder-UH27
    [Documentation]    update an order By Consumer for pickup date other than in catalog schedule.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH6}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid21}   ${cid21}   ${CatalogId3}   ${boolean[1]}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH6}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[1]} 

    ${DAY1}=  db.add_timezone_date  ${tz}   18
    ${firstname2}=  FakerLibrary.first_name
    Set Test Variable  ${email2}  ${firstname2}${CUSERPH3}.${test_mail}
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERPH3}   ${email2}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${PICKUP_DATE_NOT_SUPPORTED}"


*** Comments ***
JD-TC-UpdateOrder-UH12
    [Documentation]    update an order By provider. update order by using another provider orderid
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId1}  ${self}  ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}    ${CUSERPH3}   ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid8}  ${bool[1]}   ${sTime4}   ${eTime4}   ${DAY1}    ${CUSERPH2}  ${email}  ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"  


JD-TC-UpdateOrder-UH13
    [Documentation]    update an order By provider.(update with a far date)
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.add_timezone_date  ${tz}   17
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateOrder-UH14
    [Documentation]   update an order by provider for a past date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}  ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY2}=  db.subtract_timezone_date  ${tz}    2
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY2}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_IS_PAST}"
  
JD-TC-UpdateOrder-UH15
    [Documentation]   update an order by provider  without an order date.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup  ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${EMPTY}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_NEEDED}"
  
JD-TC-UpdateOrder-UH16
    [Documentation]   update an order by provider pickup  with delivery pickup is false.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[0]}   ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${DELIVERY_INPUT_NEEDED}"
  
JD-TC-UpdateOrder-UH17
    [Documentation]    place an order by consumer  and update with disable order settings by provider.

    clear_queue    ${PUSERNAME111}
    clear_service  ${PUSERNAME111}
    clear_customer   ${PUSERNAME111}
    clear_Item   ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid0}  ${resp.json()['id']}
    
    ${accId0}=  get_acc_id  ${PUSERNAME111}

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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity0}   maxQuantity=${maxQuantity0}  
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

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity0}   max=${maxQuantity0}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH0}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup    ${cookie}  ${accId0}   ${self}   ${CatalogId}   ${bool[1]}   ${sTime0}   ${eTime0}  ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()} 
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId0}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
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

    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}   ${sTime0}    ${eTime0}   ${DAY1}  ${CUSERPH0}  ${email}  ${countryCodes[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"       "${ORDER_SETTINGS_NOT_ENABLED}"

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}

JD-TC-UpdateOrder-UH18
    [Documentation]   update an order by provider after provider change order status to cancel.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}    ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid}   ${StatusList[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

    ${address1}=  get_address
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}    ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    
  
JD-TC-UpdateOrder-UH19
    [Documentation]   update an order by provider after consumer cancel the order.
    
    ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH2}.${test_mail}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERPH2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId1}  ${self}    ${CatalogId2}  ${bool[1]}   ${sTime0}   ${eTime0}   ${DAY1}  ${CUSERPH2}  ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id0}  ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}  ${orderid}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Cancel Order By Consumer    ${accId1}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=   Get Order By Id    ${accId1}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Change Order Status   ${orderid}   ${StatusList[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Order Status Changes by uid    ${orderid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}

    ${address1}=  get_address
    ${resp}=   Update Order For Pickup   ${orderid}   ${bool[1]}     ${sTime0}    ${eTime0}   ${DAY1}    ${CUSERPH2}    ${email}   ${countryCodes[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    