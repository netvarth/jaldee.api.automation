*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order, Rating
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${SERVICE1}   Bleach
${SERVICE3}   Makeup
${SERVICE4}   FacialBody6
${SERVICE2}   MakeupHair6
${self}      0


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

JD-TC-UpdateOrderRating-1

	[Documentation]    Consumer Order Rating.
	
    clear_queue    ${PUSERNAME250}
    clear_service  ${PUSERNAME250}
    clear_customer   ${PUSERNAME250}
    clear_Item   ${PUSERNAME250}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
   
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME250}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME250}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    Set Suite Variable    ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable    ${maxQuantity}

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
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

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
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${rating1}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating1}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating1}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}

    ${rating12}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating12}
    ${comment2}=   FakerLibrary.word
    ${resp}=  Update Order Rating  ${accId}  ${orderid1}  ${rating12}  ${comment2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating12}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][1]['comments']}  ${comment2}
*** Comments ***  
JD-TC-UpdateOrderRating-2

	[Documentation]    Consumer Rating multiple orders.
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  13  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${rating2}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating2}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid2}   ${rating2}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating2}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}
    
    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  11  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}
    
    ${rating3}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating3}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid3}   ${rating3}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid3}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating3}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}
   
JD-TC-UpdateOrderRating-3

	[Documentation]    Consumer Rating Family member's order.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  13  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${cidfor}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${rating}=  Random Int  min=1   max=5
    Set Test Variable   ${rating}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}
    
JD-TC-UpdateOrderRating-4

	[Documentation]    Rate Order without any comment.    

    clear_queue    ${PUSERNAME250}
    clear_service  ${PUSERNAME250}
    clear_customer   ${PUSERNAME250}
    clear_Item   ${PUSERNAME250}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME250}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME250}.${test_mail}

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

    ${address}=  get_address
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

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${rating1}=  Random Int  min=1   max=5
    Set Test Variable   ${rating1}
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating1}   ${empty}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${empty}

JD-TC-UpdateOrderRating-5

	[Documentation]    Rate Order by provider login.   
    
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME117}
    clear_service  ${PUSERNAME117}
    clear_customer   ${PUSERNAME117}
    clear_Item   ${PUSERNAME117}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME117}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME117}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If   ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}     Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


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

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

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

    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  1  00   
    Set Suite Variable    ${eTime3}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    Set Suite Variable    ${deliveryCharge}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Suite Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}


    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery}

    ${terminator2}=  Create Dictionary  endDate=${endDate2}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator2}
    ${pickupSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate2}   terminator=${terminator2}   timeSlots=${timeSlots}
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule2}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp2}
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery2}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    # ${cid20}=  get_id  ${CUSERNAME20}
    # Set Suite Variable   ${cid20}
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${orderNote}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCode[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${rating}=  Random Int  min=1   max=5
    Set Test Variable   ${rating3}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}


JD-TC-UpdateOrderRating-UH1

	[Documentation]    Rate Order without any rating value.
 
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  13  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${rating2}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating2}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid2}   ${rating2}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order Rating  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uId']}               ${orderid2}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating2}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment}
    
    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  11  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
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
    
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${EMPTY}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"     "${NO_RATING_AVAILABLE}"

JD-TC-UpdateOrderRating-UH2

	[Documentation]    Rate Order with a negative value.
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  13  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${cidfor}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   -1  ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_RATING}"

JD-TC-UpdateOrderRating-UH3

	[Documentation]    Rate order by giving a big number for rating.
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get HomeDelivery Dates By Catalog  ${accId}  ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${DAY1}=  db.add_timezone_date  ${tz}  13  

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  0    ${len}
        ${stime}  ${etime}=  Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}'  Get Order Time   ${i}   ${resp}
        Exit For Loop IF   '${resp.json()[${i}]['date']}' == '${DAY1}'  
        
    END

    Set Test Variable   ${sTime1}   ${stime[0]}
    Set Test Variable   ${eTime1}   ${etime[0]}

    ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${cidfor}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${rating3}=  Random Int  min=100   max=500
    Set Suite Variable   ${rating3}
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating3}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${INVALID_RATING}"


JD-TC-UpdateOrderRating-UH4

	[Documentation]    Rate order for an already rated order.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${ALREADY_RATED}"

JD-TC-UpdateOrderRating-UH5

	[Documentation]    Consumer Rating another consumer's order Schedule .

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-UpdateOrderRating-UH6

	[Documentation]    Consumer Rating without creating order Schedule .

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${EMPTY}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_order}"

JD-TC-UpdateOrderRating-UH7

	[Documentation]   Rating Added By Consumer without login  

	${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${accId}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateOrderRating-UH8

	[Documentation]   Rating Added By Consumer by another provider's account id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid1}=  get_acc_id  ${PUSERNAME99}
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${pid1}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-UpdateOrderRating-UH9

	[Documentation]    Rate already rated order by provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${rating}=  Random Int  min=1   max=5
    ${comment}=   FakerLibrary.word
    ${resp}=  Add Order Rating  ${pid}  ${orderid1}   ${rating}   ${comment}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${ALREADY_RATED}"
