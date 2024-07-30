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
${postalCode}   680306

*** Test Cases ***
JD-TC-UpdateDeliveryAddress-1
    [Documentation]     Create order by provider for Home Delivery here provider customer update delivery address 

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME114}
    clear_service  ${PUSERNAME114}
    clear_customer   ${PUSERNAME114}
    clear_Item   ${PUSERNAME114}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
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
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${itemCode4}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${itemCode5}=   FakerLibrary.word 
    ${itemName5}=   FakerLibrary.name  
    ${displayName5}=   FakerLibrary.name 
    Set Suite Variable  ${displayName5}
    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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

    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${sTime5}
    ${eTime5}=  add_timezone_time  ${tz}  2  00   
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

    ${catalogName1}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${catalogName2}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${catalogName3}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME4}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME23}+73016
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${phoneNumber1}=  Evaluate  ${PUSERNAME23}+73017
    ${firstName1}=  FakerLibrary.first_name
    ${lastName1}=  FakerLibrary.last_name
    Set Test Variable  ${email1}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address1}=  get_address
    ${city1}=  FakerLibrary.first_name
    ${landMark1}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}
    Set Suite Variable   ${data} 
    ${data1}=   Create Dictionary   phoneNumber=${phoneNumber1}   firstName=${firstName1}   lastName=${lastName1}   email=${email1}  address=${address1}   city=${city1}  postalCode=${postalCode}  landMark=${landMark1}   countryCode=${countryCodes[1]}
    Set Suite Variable   ${data1}
    # ${datalist}=  Create List  ${data}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  ${data1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Delivery Address     ${cid20}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${phoneNumber_1}   ${resp.json()[0]['phoneNumber']}
    Set Suite Variable  ${email_1}         ${resp.json()[0]['email']}
    Set Suite Variable  ${address_1}       ${resp.json()[0]['address']}
    Set Suite Variable  ${phoneNumber_2}   ${resp.json()[1]['phoneNumber']}
    Set Suite Variable  ${email_2}         ${resp.json()[1]['email']}
    Set Suite Variable  ${address_2}       ${resp.json()[1]['address']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId3}   ${boolean[1]}   ${data}  ${sTime4}    ${eTime4}   ${DAY1}    ${phoneNumber_1}    ${email_1}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
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
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address_1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}             ${phoneNumber_1}
    Should Be Equal As Strings  ${resp.json()['email']}                   ${email_1}
    
JD-TC-UpdateDeliveryAddress-2
    [Documentation]     Create order by provider for Home Delivery here provider customer update delivery address with same address details of another customer

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME6}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid21}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Update Delivery Address     ${cid21}   ${data}  ${data1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Delivery Address     ${cid21}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${phoneNumber_1}   ${resp.json()[0]['phoneNumber']}
    Set Test Variable  ${email_1}         ${resp.json()[0]['email']}
    Set Test Variable  ${address_1}       ${resp.json()[0]['address']}
    Set Test Variable  ${phoneNumber_2}   ${resp.json()[1]['phoneNumber']}
    Set Test Variable  ${email_2}         ${resp.json()[1]['email']}
    Set Test Variable  ${address_2}       ${resp.json()[1]['address']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId3}   ${boolean[1]}   ${data}  ${sTime4}    ${eTime4}   ${DAY1}    ${phoneNumber_1}    ${email_1}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid4}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address_1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}             ${phoneNumber_1}
    Should Be Equal As Strings  ${resp.json()['email']}                   ${email_1}

JD-TC-UpdateDeliveryAddress-3
    [Documentation]     Create order by provider for Home Delivery here provider customer update delivery address 

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME115}
    clear_service  ${PUSERNAME115}
    clear_customer   ${PUSERNAME115}
    clear_Item   ${PUSERNAME115}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid2}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId4}=  get_acc_id  ${PUSERNAME115}
    Set Suite Variable  ${accId4} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME114}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

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
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${itemCode4}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${itemCode5}=   FakerLibrary.word 
    ${itemName5}=   FakerLibrary.name  
    ${displayName5}=   FakerLibrary.name 
    Set Suite Variable  ${displayName5}
    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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

    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${sTime5}
    ${eTime5}=  add_timezone_time  ${tz}  2  00   
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

    ${catalogName1}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${catalogName2}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${catalogName3}=   FakerLibrary.name 
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList2}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME4}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid24}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Update Delivery Address     ${cid24}   ${data}  ${data1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Delivery Address     ${cid24}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${phoneNumber_1}   ${resp.json()[0]['phoneNumber']}
    Set Test Variable  ${email_1}         ${resp.json()[0]['email']}
    Set Test Variable  ${address_1}       ${resp.json()[0]['address']}
    Set Test Variable  ${phoneNumber_2}   ${resp.json()[1]['phoneNumber']}
    Set Test Variable  ${email_2}         ${resp.json()[1]['email']}
    Set Test Variable  ${address_2}       ${resp.json()[1]['address']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME115}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid24}   ${cid24}   ${CatalogId3}   ${boolean[1]}   ${data1}  ${sTime4}    ${eTime4}   ${DAY1}    ${phoneNumber_1}    ${email_1}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid5}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid5} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid5}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address_1}
    Should Be Equal As Strings  ${resp.json()['phoneNumber']}             ${phoneNumber_1}
    Should Be Equal As Strings  ${resp.json()['email']}                   ${email_1}
        

JD-TC-UpdateDeliveryAddress-UH1
    [Documentation]      Update delivery address without login

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 


JD-TC-UpdateDeliveryAddress-UH2
    [Documentation]     Update delivery address with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
    

JD-TC-UpdateDeliveryAddress-UH3
    [Documentation]     Update delivery address with another provider customer id 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid24}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
    
JD-TC-UpdateDeliveryAddress-UH4
    [Documentation]     Update delivery address without address 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${EMPTY}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_ADDRESS}"
    
JD-TC-UpdateDeliveryAddress-UH5

    [Documentation]     Update delivery address without phone 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${EMPTY}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_PHONE}"
    
JD-TC-UpdateDeliveryAddress-UH6

    [Documentation]     Update delivery address without name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${EMPTY}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_FIRST_NAME}"
    

JD-TC-UpdateDeliveryAddress-UH7

    [Documentation]     Update delivery address without email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${EMPTY}  address=${address}   city=${city}  postalCode=${postalCode}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_EMAIL_FOR_DELIVERY_ADDRESS}"
    
JD-TC-UpdateDeliveryAddress-UH8

    [Documentation]     Update delivery address without postalcode

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phoneNumber}=  Evaluate  ${PUSERNAME24}+73009
    ${firstName}=  FakerLibrary.first_name
    ${lastName}=  FakerLibrary.last_name
    Set Test Variable  ${email}  ${lastName}${CUSERNAME4}.${test_mail} 
    ${address}=  get_address
    ${city}=  FakerLibrary.first_name
    ${landMark}=  FakerLibrary.first_name

    ${data}=   Create Dictionary   phoneNumber=${phoneNumber}   firstName=${firstName}   lastName=${lastName}   email=${email}  address=${address}   city=${city}  postalCode=${EMPTY}  landMark=${landMark}   countryCode=${countryCodes[1]}

    ${resp}=   Update Delivery Address     ${cid20}   ${data}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_POSTAL_CODE}"
    