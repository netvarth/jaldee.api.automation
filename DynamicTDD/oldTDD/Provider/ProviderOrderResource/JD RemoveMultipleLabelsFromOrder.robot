*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Order  Label
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}    0
${digits}       0123456789
${discount}        Disc11
${coupon}          wheat
&{Emptydict}

*** Test Cases ***

JD-TC-RemoveMultipleLabelsFromOrder-1

    [Documentation]  Remove multiple labels from one order.(Homedelivery)

    clear_queue    ${PUSERNAME48}
    clear_service  ${PUSERNAME48}
    clear_customer   ${PUSERNAME48}
    clear_Item   ${PUSERNAME48}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME48}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME48}.${test_mail}

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
    Set Suite Variable  ${sTime1} 
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable  ${eTime1}   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable  ${minQuantity} 

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable  ${maxQuantity} 

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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
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
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    clear_Label  ${PUSERNAME48}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}  label=${labelname[0]}
    ...   displayName=${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}
    
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${DAY1}
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
    Set Test Variable  ${email}  ${firstname}${CUSERNAME9}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME9}    ${email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict1}=  Create Label Dictionary  ${lbl_name}  ${lbl_value}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}
    Set Suite Variable  ${label_dict1} 

    ${resp}=  Add Multiple Labels for Order   ${label_dict1}  ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid1}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names1}=  Create List  ${lbl_name}  ${lbl_name2}  ${lbl_name3}
    Set Suite Variable  ${label_names1} 

    ${resp}=  Remove Multiple Labels from Order   ${label_names1}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid1}  
    # Should Not Contain   ${resp.json()}   ${label}
    # Should Not Contain  ${resp.json()['label']}   ${label_dict1}

JD-TC-RemoveMultipleLabelsFromOrder-2

    [Documentation]  Remove multiple labels from one order.(pickup)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME9}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME9}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary   ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid3}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[0]}   storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List   ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response   ${resp}  uid=${orderid3}  label=${Emptydict}


JD-TC-RemoveMultipleLabelsFromOrder-3
    [Documentation]  Remove one label from multile labels 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}


    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
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

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME9}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME9}    ${email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}


    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary   ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}


    END

    @{label_names}=  Create List   ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END
   

JD-TC-RemoveMultipleLabelsFromOrder-4
    [Documentation]     Remove multiple labels from a orders.(order from provider side) 

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
    Set Test Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME121}
  
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME121}.${test_mail}

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
    Set Test Variable  ${catalogItem}
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus1}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    Set Test Variable  ${paymentType2}     ${AdvancedPaymentType[1]}

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

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}

    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}
    

    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid20}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

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
      
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME121}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid20}   ${cid20}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[0]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}
    
    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List  ${lbl_name1}  ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response   ${resp}  uid=${orderid}  label=${Emptydict}


JD-TC-RemoveMultipleLabelsFromOrder-5

    [Documentation]  Remove multiple labels from multiple orders.

    clear_queue    ${PUSERNAME56}
    clear_service  ${PUSERNAME56}
    clear_customer   ${PUSERNAME56}
    clear_Item   ${PUSERNAME56}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME56}
  
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME56}.${test_mail}

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

    ${minQuantity1}=  Random Int  min=1   max=30
    
    ${maxQuantity1}=  Random Int  min=${minQuantity1}   max=50
    
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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
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
    Set Test Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    clear_Label  ${PUSERNAME56}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id}  label=${labelname[0]}
    ...   displayName=${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}
    
    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
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
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME9}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId1}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME9}    ${email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid4}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId1}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME9}    ${email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid5}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name}  ${lbl_value}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid4}   ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid4}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    ${resp}=   Get Order By uid   ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid5}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[1]}   storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List  ${lbl_name}  ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid4}  ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response   ${resp}  uid=${orderid4}  label=${Emptydict}

    ${resp}=   Get Order By uid   ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response   ${resp}  uid=${orderid5}  label=${Emptydict}

JD-TC-RemoveMultipleLabelsFromOrder-UH1
    [Documentation]  Remove label without provider login

    ${resp}=  Remove Multiple Labels from Order    ${label_names1}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-RemoveMultipleLabelsFromOrder-UH2
    [Documentation]  Remove label by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Remove Multiple Labels from Order    ${label_names1}  ${orderid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-RemoveMultipleLabelsFromOrder-UH3
    [Documentation]  Remove label not added in appointments

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_id0}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id0}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}


    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME9}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME11}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name0}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value0}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}


    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary   ${lbl_name0}  ${lbl_value0}  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[0]}   storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List   ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${LABEL_ALREADY_ADD_REMOVE}"

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name0}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value0}
        ...    ELSE IF     '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}

    END
   
JD-TC-RemoveMultipleLabelsFromOrder-UH4
    [Documentation]  Remove same label twice

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_id0}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id0}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}


    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
   
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name0}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value0}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}


    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary   ${lbl_name0}  ${lbl_value0}  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}  

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[0]}   storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List   ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${LABEL_ALREADY_ADD_REMOVE}"

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name0}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value0}
        ...    ELSE IF     '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
    END
   
   
JD-TC-RemoveMultipleLabelsFromOrder-UH5
    [Documentation]  Remove label without label name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME48}
    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}


    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME13}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME13}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME13}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary   ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  

    ${resp}=  Add Multiple Labels for Order   ${label_dict}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[0]}   storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  

    ${items}     Get Dictionary Items   ${resp.json()['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    @{label_names}=  Create List   ${EMPTY}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
JD-TC-RemoveMultipleAppointmentLabel-UH6
    [Documentation]  Remove label without adding any

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME48}
    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}


    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME14}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME14}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId}    ${self}    ${CatalogId1}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME14}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    
    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response   ${resp}  uid=${orderid}  orderDate=${DAY1}  
    ...   homeDelivery=${bool[0]}   storePickup=${bool[1]}  orderStatus=${orderStatuses[0]}  

    @{label_names}=  Create List   ${lbl_name1}  ${lbl_name2}  ${lbl_name3}
    ${resp}=  Remove Multiple Labels from Order   ${label_names}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${LABEL_ALREADY_ADD_REMOVE}"

    ${resp}=   Get Order By uid   ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   