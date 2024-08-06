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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}    0

*** Test Cases ***

JD-TC-GetOrderByCriteria-1
    [Documentation]    Get an order details by order id.

    clear_queue    ${PUSERNAME128}
    clear_service  ${PUSERNAME128}
    clear_customer   ${PUSERNAME128}
    clear_Item   ${PUSERNAME128}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME128}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accountId}=  get_acc_id  ${PUSERNAME128}
    Set Suite Variable  ${accountId} 

    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME128}.${test_mail}

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

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${fname}=   FakerLibrary.first_name
    ${lname}=    FakerLibrary.last_name
    Set Test Variable      ${fname}
    Set Test Variable      ${lname}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${fname}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${fname}   lastName=${lname}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullName}   Set Variable    ${fname} ${lname}
    Set Test Variable  ${fullName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
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
    Set Suite Variable  ${email}  ${firstname}${consumerPhone}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery  ${cookie}  ${accountId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${consumerPhone}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accountId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no1}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME128}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jcons_id1}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${resp}=   Create Order For Pickup   ${cookie}  ${accountId}    ${mem_id}    ${CatalogId1}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${consumerPhone}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accountId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no2}  ${resp.json()['orderNumber']}

    ${DAY2}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable   ${DAY2}

    ${resp}=   Create Order For Pickup  ${cookie}  ${accountId}    ${self}    ${CatalogId2}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${consumerPhone}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accountId}  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no3}  ${resp.json()['orderNumber']}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=   Get Order By Criteria  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1}  
    Verify Response List    ${resp}  1    uid=${orderid2}

JD-TC-GetOrderByCriteria-2
    [Documentation]    Get an order details by account id.

    clear_queue    ${PUSERNAME130}
    clear_service  ${PUSERNAME130}
    clear_customer   ${PUSERNAME130}
    clear_Item   ${PUSERNAME130}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accountId1}=  get_acc_id  ${PUSERNAME130}
    Set Test Variable  ${accountId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME130}.${test_mail}

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

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
    Set Test Variable  ${email}  ${firstname}${consumerPhone}.${test_mail}

    ${resp}=   Create Order For HomeDelivery  ${cookie}  ${accountId1}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${consumerPhone}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accountId1}  ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no4}  ${resp.json()['orderNumber']}

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   account-eq=${accountId}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2} 

    ${resp}=   Get Order By Criteria   account-eq=${accountId1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 

JD-TC-GetOrderByCriteria-3
    [Documentation]    Get an order details by home delivery = true.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   homeDelivery-eq=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid4} 
    
JD-TC-GetOrderByCriteria-4
    [Documentation]    Get an order details by pickup = true.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   storePickup-eq=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid2} 

JD-TC-GetOrderByCriteria-5
    [Documentation]    Get an order details by pickup = false.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   storePickup-eq=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid4} 

JD-TC-GetOrderByCriteria-6
    [Documentation]    Get an order details by order status received.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderStatus-eq=${orderStatuses[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2} 
    Verify Response List    ${resp}  2    uid=${orderid4} 

JD-TC-GetOrderByCriteria-7
    [Documentation]    Get an order details by order status confirmed.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderStatus-eq=${orderStatuses[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-8
    [Documentation]    Get an order details by order date.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderDate-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2}
    Verify Response List    ${resp}  2    uid=${orderid4}  

# JD-TC-GetOrderByCriteria-9
#     [Documentation]    Get an order details by future order date.

#     ${resp}=  Consumer Login  ${consumerPhone}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=   Get Order By Criteria   orderDate-eq=${DAY2}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-10
    [Documentation]    Get an order details by order number.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderNumber-eq=${order_no1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 

    ${resp}=   Get Order By Criteria   orderNumber-eq=${order_no2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid2} 

    ${resp}=   Get Order By Criteria   orderNumber-eq=${order_no4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid4} 
    
JD-TC-GetOrderByCriteria-11
    [Documentation]    Get future order details by order number.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderNumber-eq=${order_no3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-12
    [Documentation]    Get an order details by order mode (online order).

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderMode-eq=${order_mode[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2}
    Verify Response List    ${resp}  2    uid=${orderid4}  

JD-TC-GetOrderByCriteria-13
    [Documentation]    Get an order details by order mode(walkin order).

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderMode-eq=${order_mode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-14
    [Documentation]    Get an order details by order mode(phone order).

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   orderMode-eq=${order_mode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-15
    [Documentation]    Get an order details by first name.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   firstName-eq=${fname}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid4}

JD-TC-GetOrderByCriteria-16
    [Documentation]    Get an order details by last name.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   lastName-eq=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid4}

JD-TC-GetOrderByCriteria-17
    [Documentation]    Get an order details by email id.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   email-eq=${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2}

JD-TC-GetOrderByCriteria-18
    [Documentation]    Get an order details by phone number.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   phoneNumber-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
    Verify Response List    ${resp}  1    uid=${orderid2}
    Verify Response List    ${resp}  2    uid=${orderid4}

JD-TC-GetOrderByCriteria-19
    [Documentation]    Get an order details by jaldee id.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   jaldeeId-eq=${jcons_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid1} 
 
JD-TC-GetOrderByCriteria-20
    [Documentation]    Get an order details by family member's last name.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid2} 
  
JD-TC-GetOrderByCriteria-21
    [Documentation]    Get an order details by family member's first name.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   firstName-eq=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Verify Response List    ${resp}  0    uid=${orderid2} 

JD-TC-GetOrderByCriteria-22
    [Documentation]    Get an order details by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Criteria   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-23
    [Documentation]    Get an order details by invalid account id.

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Order By Criteria   account-eq=000
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetOrderByCriteria-UH1
    [Documentation]    Get an order details without login.

    ${resp}=   Get Order By Criteria   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  


      














