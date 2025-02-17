*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}    0
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf


*** Test Cases ***

JD-TC-OrderByProviderForPickup
    [Documentation]    Place an order By Provider for pickup.
    
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${c15_Uid}     ${resp.json()['id']}
    Set Suite Variable  ${c15_UName}   ${resp.json()['userName']}
    clear_Consumermsg  ${CUSERNAME23}
    clear_Providermsg  ${PUSERNAME59}
    clear_queue    ${PUSERNAME59}
    clear_service  ${PUSERNAME59}
    clear_customer   ${PUSERNAME59}
    clear_Item   ${PUSERNAME59}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME59}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME59}.${test_mail}

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
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}    Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    
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
    
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Suite Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Suite Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Suite Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Suite Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  05
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30   
    Set Suite Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  0  35  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}   0  55 
    Set Suite Variable    ${eTime2}


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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery}
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
    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME23}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid18}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME23}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid11}  ${orderid[0]}

    ${DATE1}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE1}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}

    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${orderNote}

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}


    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no11}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no12}  ${resp.json()['orderNumber']}


JD-TC-OrderByProviderForHomeDelivery
    [Documentation]    Place an order By Provider for Home Delivery.           

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY10}=  db.add_timezone_date  ${tz}   10
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4
                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid21}  ${orderid[0]}

    ${DATE10}=  Convert Date  ${DAY10}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE10}

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY10}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid22}  ${orderid[0]}


    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid21}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no21}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid22}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no22}  ${resp.json()['orderNumber']}


JD-TC-OrderByConsumerForHomeDelivery
    [Documentation]    Place an order By Consumer for Home Delivery.

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${DATE12}=  Convert Date  ${DAY12}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE12}
    # ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY12}    ${sTime1}    ${eTime1}    ${CUSERNAME20}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid31}  ${orderid[0]}

    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId3}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY12}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid32}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid31}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no31}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid32}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no32}  ${resp.json()['orderNumber']}


JD-TC-OrderByConsumerForPickup
    [Documentation]    Place an order By consumer for pickup.

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${DAY12}    ${sTime1}    ${eTime1}    ${CUSERNAME20}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid41}  ${orderid[0]}

    ${resp}=   Create Order For Pickup  ${cookie}  ${accId3}    ${self}    ${CatalogId2}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY12}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid42}  ${orderid[0]}


    ${resp}=   Get Order By Id  ${accId3}  ${orderid41}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no41}  ${resp.json()['orderNumber']}
    
    ${resp}=   Get Order By Id  ${accId3}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no42}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get Order by uid    ${orderid41} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${orderid42} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ConsumerOrderCommunication-1
    [Documentation]  Send order comunication message to consumer without attachment
    # ${weekday}=  get_timezone_weekday  ${tz}

    clear_consumer_msgs  ${CUSERNAME23}
    clear_consumer_msgs  ${CUSERNAME20}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}
    Set Suite Variable  ${c20_Uid}     ${resp.json()['id']}
    Set Suite Variable  ${c20_UName}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${filecap_dict1}=  Create Dictionary   file=${EMPTY}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    # @{fileswithcaption}=  Create List   ${EMPTY}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid41}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   4s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c20_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c20_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Set Test Variable  ${messageId1}    ${resp.json()[0]['messageId']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bs_id}  ${resp.json()['id']}
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}
  
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c20_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c20_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Be Equal As Strings  ${resp.json()[0]['service']}        Order '${order_no41}' on ${DATE12}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}      ${bs_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}    ${bsname}
    Should Be Equal As Strings  ${resp.json()[0]['read']}           ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['messageId']}      ${messageId1}
    


    

JD-TC-ConsumerOrderCommunication-2
    [Documentation]  Send order comunication message to consumer with attachment
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}

    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1} 

    Should Be Equal As Strings  ${resp.json()[0]['service']}        Order '${order_no11}' on ${DATE1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}      ${bs_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}    ${bsname}
    Should Be Equal As Strings  ${resp.json()[0]['read']}           ${bool[0]}
    Set Test Variable  ${messageId2}    ${resp.json()[0]['messageId']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}
    

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
   
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Should Be Equal As Strings  ${resp.json()[0]['service']}        Order '${order_no11}' on ${DATE1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}      ${bs_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}    ${bsname}
    Should Be Equal As Strings  ${resp.json()[0]['read']}           ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['messageId']}      ${messageId2}
    

JD-TC-ConsumerOrderCommunication-3
    [Documentation]  Send order comunication message to consumer with multiple files using file types jpeg, png and pdf
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3
    
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][2]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][2]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}
   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    
JD-TC-ConsumerOrderCommunication-4
    [Documentation]  Send order comunication message to consumer with attachment but without caption
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${None}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${None}

 

JD-TC-ConsumerOrderCommunication-5
    [Documentation]  Send order comunication message to consumer after staring appointment
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

   

JD-TC-ConsumerOrderCommunication-6
    [Documentation]  Send order comunication message to consumer after completing appointment
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}


JD-TC-ConsumerOrderCommunication-7
    [Documentation]  Send order comunication message to consumer after cancelling Order
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    
    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid22}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=   Get Order By Id    ${accId3}   ${orderid22}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid22}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}



JD-TC-ConsumerOrderCommunication-8
    [Documentation]  Send order comunication message to provider after rejecting order
    
    clear_consumer_msgs  ${CUSERNAME23}
    clear_provider_msgs  ${PUSERNAME59}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Change Order Status   ${orderid11}   ${orderStatuses[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  2s
    ${resp}=  Get Order Status Changes by uid    ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[12]}

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}


    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${c15_Uid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}      ${c15_UName}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${accId3}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ConsumerOrderCommunication-UH1
    [Documentation]  Send order comunication message to consumer without login
    ${empty_cookie}=  Create Dictionary
    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${empty_cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED} 

  
JD-TC-ConsumerOrderCommunication-UH2
    [Documentation]  Send order comunication message to provider by provider login 
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME37}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    403
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

  

JD-TC-ConsumerOrderCommunication-UH3
    [Documentation]  Send order comunication message using invalid Order id
     ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  00000ab  ${accId3}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}   00000ab   ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    404
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_ORDER_UID}



JD-TC-ConsumerOrderCommunication-UH4
    [Documentation]  Send order comunication message by another consumer login

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME18}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    # ${resp}=  Imageupload.COrderCommunication   ${cookie}  ${orderid11}  ${accId3}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile} 
    ${resp}=  Imageupload.consumerOrderCommunication   ${cookie}  ${accId3}  ${orderid11}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption} 
    Log  ${resp}
    Should Be Equal As Strings   ${resp.status_code}    403
    Should Be Equal As Strings   ${resp.json()}   ${NO_PERMISSION}
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}  ${LOGIN_NO_ACCESS_FOR_URL}

    



