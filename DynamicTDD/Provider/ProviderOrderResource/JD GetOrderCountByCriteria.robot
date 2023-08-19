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
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${self}    0
${digits}       0123456789
${discount}        Disc11
${coupon}          wheat

*** Test Cases ***

JD-TC-Getordercountbycriteria-1
    [Documentation]   create a order and Get order count By date after two week
    
    clear_queue    ${PUSERNAME110}
    clear_service  ${PUSERNAME110}
    clear_customer   ${PUSERNAME110}
    clear_Item   ${PUSERNAME110}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}

    ${accId}=  get_acc_id  ${PUSERNAME110}
    Set Suite Variable  ${accId} 


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME110}.ynwtest@netvarth.com

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
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${displayName2}=   FakerLibrary.name 
    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2float}=  twodigitfloat  ${price2}

    ${itemName2}=   FakerLibrary.name  

    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 

    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}

    ${note2}=  FakerLibrary.Sentence   

    ${itemCode2}=   FakerLibrary.word 

    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[1]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    # ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${startDate1}=  db.get_date_by_timezone  ${tz}
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
    Set Suite Variable    ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable    ${maxQuantity}

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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}

    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem1}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${item}=  Create Dictionary  itemId=${item_id2}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create List   ${catalogItem1}

    ${catalogName1}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    # ${filterdate}=  get_date_time_milli
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email0}  ${firstname}${CUSERNAME2}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME2}    ${email0}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId}   ${orderid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME2}    ${email0}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId}   ${orderid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email2}  ${firstname}${CUSERNAME2}.ynwtest@netvarth.com

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME2}    ${email2}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId}   ${orderid3}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  AddCustomer  ${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jcons_id1}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME3}.ynwtest@netvarth.com

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME3}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId}   ${orderid4}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable     ${jdconID}   ${resp.json()['jaldeeConsumer']['id']}       


    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME3}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid5}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${accId}   ${orderid5}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${ordernumber1}     ${resp.json()['orderNumber']}     

    ${resp}=  Get Order count by Criterias   orderDate-eq=${DAY1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  5

JD-TC-Getordercountbycriteria-2
    [Documentation]    Get order By homedelivery true

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   homeDelivery-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  5


JD-TC-Getordercountbycriteria-4
    [Documentation]    Get order By firstname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   firstName-eq=${fname}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-Getordercountbycriteria-5
    [Documentation]    Get order By lastname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   lastName-eq=${lname1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  2


JD-TC-Getordercountbycriteria-6
    [Documentation]    Get order By email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   email-eq=${email0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Getordercountbycriteria-7
    [Documentation]    Get order By phonenumber

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   phoneNumber-eq=${CUSERNAME3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  2

    
JD-TC-Getordercountbycriteria-8
    [Documentation]    Get order By jaldeeid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   jaldeeId-eq=${jcons_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-Getordercountbycriteria-9
    [Documentation]    Get order By jaldeeconsumer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   jaldeeConsumer-eq=${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Getordercountbycriteria-10
    [Documentation]    Get order By ordermode is online

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   orderMode-eq=${order_mode[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  5

JD-TC-Getordercountbycriteria-11
    [Documentation]    Get order By ordernumber
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   orderNumber-eq=${ordernumber1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Getordercountbycriteria-12
    [Documentation]    Get order By uid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   uid-eq=${orderid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    
JD-TC-Getordercountbycriteria-13
    [Documentation]    Get order By storepikup is false
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   storePickup-eq=${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  5

JD-TC-Getordercountbycriteria-14
    [Documentation]    Get order By orderstatus is order recieved

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   orderStatus-eq=${orderStatuses[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  5


JD-TC-Getordercountbycriteria-15
    [Documentation]    Update Delivery Charge By provider for home delivery.check bill after order taxable and non taxable items.

    clear_queue    ${PUSERNAME119}
    clear_service  ${PUSERNAME119}
    clear_customer   ${PUSERNAME119}
    clear_Item   ${PUSERNAME119}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME119}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid3}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME119}
    Set Test Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME119}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid3}   ${firstname}   ${lastname}   ${email_id}
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
    Set Test Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Test Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Test Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Test Variable  ${promoPrice2}

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

    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Test Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  3  30   
    Set Test Variable    ${eTime3}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Test Variable    ${deliveryCharge3}

    ${NewCharge}=  Random Int  min=110   max=150
    ${NewdeliveryCharge}=  Convert To Number  ${NewCharge}  1
    Set Test Variable    ${NewdeliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Test Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Test Variable   ${maxQuantity3}

    ${catalogName}=   FakerLibrary.name  
    
    ${catalogDesc}=   FakerLibrary.name 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${NewhomeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${NewdeliveryCharge}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=18

    ${soon}=  Random Int  min=0   max=0
    
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5
    
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid7}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid7}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME119}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid7} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid7}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}


    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    Set Test Variable   ${netTotal}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    Set Test Variable   ${amountDue}

    ${resp}=  Get Bill By UUId  ${orderid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid7}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Test Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid7}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}
    ${total1}=  Convert To twodigitfloat  ${total1}
    Set Test Variable   ${total1}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid7}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid7}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME119}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid7}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 

    ${resp}=  Get Order count by Criterias   uid-eq=${orderid7} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  1
 

    ${resp}=  Get Order count by Criterias   orderDate-eq=${DAY1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Getordercountbycriteria-16
   
    [Documentation]    Get an order details for store pickup is true.

    clear_queue    ${PUSERNAME120}
    clear_service  ${PUSERNAME120}
    clear_customer   ${PUSERNAME120}
    clear_Item   ${PUSERNAME120}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME120}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME120}.ynwtest@netvarth.com

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

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus1}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14

    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=0   max=0

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.ynwtest@netvarth.com

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId2}    ${self}    ${CatalogId2}   ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid6}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   uid-eq=${orderid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  1
 
    ${resp}=  Get Order count by Criterias   storePickup-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Getordercountbycriteria-17
    [Documentation]    Get an order details for store pickup.and change the status to cancell and get details

    clear_queue    ${PUSERNAME120}
    clear_service  ${PUSERNAME120}
    clear_customer   ${PUSERNAME120}
    clear_Item   ${PUSERNAME120}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME120}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME120}.ynwtest@netvarth.com

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

    ${itemCode2}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id2}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
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

    ${catalogName1}=   FakerLibrary.name  

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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14

    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=0   max=0

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${address}=  get_address  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.ynwtest@netvarth.com

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For Pickup   ${cookie}  ${accId2}    ${self}    ${CatalogId2}   ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order By Criterias   storePickup-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List    ${resp}  0    uid=${orderid2}
    # Verify Response List    ${resp}  1    uid=${orderid6}     

    ${resp}=  Change Order Status   ${orderid2}   ${StatusList[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order count by Criterias   orderStatus-eq=${StatusList[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Order count by Criterias   storePickup-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Getordercountbycriteria-18
    [Documentation]     Create order by provider for Home Delivery when payment type is NONE (No Advancepayment)

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME121}
    clear_service  ${PUSERNAME121}
    clear_customer   ${PUSERNAME121}
    clear_Item   ${PUSERNAME121}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME121}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME121}.ynwtest@netvarth.com

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
    ${displayName3}=   FakerLibrary.name 
    ${displayName4}=   FakerLibrary.name
    ${displayName5}=   FakerLibrary.name 
 
    ${price1float}=  twodigitfloat  ${price2}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
   
    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence  

    ${itemCode3}=   FakerLibrary.word 
    ${itemCode4}=   FakerLibrary.word 
    ${itemCode5}=   FakerLibrary.word 


    ${promoLabel1}=   FakerLibrary.word 
    ${itemName3}=   FakerLibrary.word 
    ${itemName4}=   FakerLibrary.word 
    ${itemName5}=   FakerLibrary.word 


    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id4}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id5}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15    

    ${startDate2}=  db.add_timezone_date  ${tz}  5  
    ${endDate2}=  db.add_timezone_date  ${tz}  25      

    ${sTime3}=  add_timezone_time  ${tz}  0  15  

    ${eTime3}=  add_timezone_time  ${tz}  1  00   
    
    ${noOfOccurance}=  Random Int  min=0   max=0

    # ${sTime3}=  add_timezone_time  ${tz}  0  15  
    
    # ${eTime3}=  add_timezone_time  ${tz}  1  00   
    
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
    
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    
    ${terminator2}=  Create Dictionary  endDate=${endDate2}  noOfOccurance=${noOfOccurance}
    ${pickupSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate2}   terminator=${terminator2}   timeSlots=${timeSlots}
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule2}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery2}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus1}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14

    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${catalogName2}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}

    ${catalogName3}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus1}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    # ${cid20}=  get_id  ${CUSERNAME20}
    # Set Suite Variable   ${cid20}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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
      
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME121}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}

    ${resp}=  Get Order count by Criterias   orderNumber-eq=${ordernumber} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Order count by Criterias   uid-eq=${orderid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  1


# JD-TC-Getordercountbycriteria-UH1
#     [Documentation]    Get order count By account of another provider accoutid

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Order By Criterias   account-eq=${accId1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
    
#     ${resp}=  Get Order count by Criterias   account-eq=${accId1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Getordercountbycriteria-UH2
    [Documentation]    Get order count By without login

    ${resp}=  Get Order count by Criterias   homeDelivery-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  

JD-TC-Getordercountbycriteria-UH3
    [Documentation]  Get order count with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order By Criterias   homeDelivery-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

    ${resp}=  Get Order count by Criterias   homeDelivery-eq=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-Getordercountbycriteria-UH4
    [Documentation]    Get order count By another provider orderid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order count by Criterias   uid-eq=${orderid6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()}  0




