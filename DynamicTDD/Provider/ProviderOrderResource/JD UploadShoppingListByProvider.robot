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


*** Test Cases ***

JD-TC-Upload_ShoppingList_By_Provider-1
    [Documentation]    Place an order By Provider for pickup.

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    
    clear_queue    ${PUSERNAME73}
    clear_service  ${PUSERNAME73}
    clear_customer   ${PUSERNAME73}
    clear_Item   ${PUSERNAME73}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME73}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME73}.ynwtest@netvarth.com

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

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    Set Suite Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  1  05  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  15   
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

    ${resp}=  AddCustomer  ${CUSERNAME32}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME32}
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
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME32}.ynwtest@netvarth.com

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  uuid=${orderid1}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    # Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid1}  ${accId3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    

JD-TC-Upload_ShoppingList_By_Provider-2
    [Documentation]    Place an order By Provider for Home Delivery.           

    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY10}=  db.add_timezone_date  ${tz}   10
    ${C_firstName}=   FakerLibrary.first_name 
    Set Suite Variable  ${C_firstName}
    ${C_lastName}=   FakerLibrary.name 
    Set Suite Variable  ${C_lastName}
    ${C_num1}    Random Int  min=123456   max=999999
    Set Suite Variable  ${C_num1}
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Suite Variable  ${CUSERPH}
    Set Suite Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    Set Suite Variable  ${homeDeliveryAddress}
    ${city}=  FakerLibrary.city
    Set Suite Variable  ${city}
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${landMark}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}
    sleep  02s
    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    billPaymentStatus=${paymentStatus[0]}
    # Verify Response  ${resp}  uuid=${orderid1}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    # Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 


    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid2}  ${accId3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Upload_ShoppingList_By_Provider-3
    [Documentation]    Place an order By Provider for family member.
    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember  ${fname}  ${lname}  ${dob}  ${gender}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id2}  ${resp.json()}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid15}  ${firstname}  ${lastname}  ${dob}  ${gender}  ${CUSERNAME32}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid15}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${CUSERNAME32}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid15}
    Log  ${resp.json()}

    Verify Response List  ${resp}  0  id=${mem_id}  firstName=${firstname}   lastName=${lastname}  status=${status[0]}  parent=${cid15}
    Verify Response List  ${resp}  1  id=${mem_id1}  firstName=${firstname1}   lastName=${lastname1}  status=${status[0]}  parent=${cid15}

    ${resp}=  ListFamilyMemberByProvider  ${cid15}

    ${DAY10}=  db.add_timezone_date  ${tz}   10
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${mem_id}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime2}    ${eTime2}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid3}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Upload_ShoppingList_By_Provider-4
    [Documentation]    Place an order By Provider using two items_list images.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY10}=  db.add_timezone_date  ${tz}   10
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid41}  ${orderid[0]}

    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid42}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid41}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-Upload_ShoppingList_By_Provider-5
    [Documentation]    Place an order By Provider for today.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${TODAY}=    db.add_timezone_date  ${tz}   10
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${TODAY}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid5}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Upload_ShoppingList_By_Provider-6
    [Documentation]    Provider place the order for two consumers using same item_list images.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME32}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  1
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid61}  ${orderid[0]}


    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid18}   ${caption}   ${cid18}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid62}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid61}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid62}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Upload_ShoppingList_By_Provider-UH1
    [Documentation]    Place an order By Provider for Home Delivery without home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${EMPTY}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_ADDRESS}"
    

JD-TC-Upload_ShoppingList_By_Provider-UH2
    [Documentation]    Place an order By Provider for Home Delivery without phone number in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${EMPTY}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${INVALID_PHONE}"


JD-TC-Upload_ShoppingList_By_Provider-UH3
    [Documentation]    Place an order By Provider for Home Delivery without firstname in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${EMPTY}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_FIRST_NAME}"


JD-TC-Upload_ShoppingList_By_Provider-UH4
    [Documentation]    Place an order By Provider for Home Delivery without lastname in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${EMPTY}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_LAST_NAME}"


JD-TC-Upload_ShoppingList_By_Provider-UH5
    [Documentation]    Place an order By Provider for Home Delivery without email in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${EMPTY}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_AN_EMAIL}"


JD-TC-Upload_ShoppingList_By_Provider-UH6
    [Documentation]    Place an order By Provider for Home Delivery without city in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${EMPTY}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_CITY_NAME}"


JD-TC-Upload_ShoppingList_By_Provider-UH7
    [Documentation]    Place an order By Provider for Home Delivery without postalcode in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${EMPTY}    landMark=${landMark}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PROVIDE_POSTAL_CODE}"


JD-TC-Upload_ShoppingList_By_Provider-UH8
    [Documentation]    Place an order By Provider for Home Delivery without country_code in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${EMPTY}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${COUNTRY_CODEREQUIRED}"


JD-TC-Upload_ShoppingList_By_Provider-10
    [Documentation]    Place an order By Provider for Home Delivery without landmark in home delivery address.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}   2

    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${EMPTY}   countryCode=${countryCodes[0]}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address1}   ${DAY2}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid10}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid10}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Upload_ShoppingList_By_Provider-11
    [Documentation]   place an order by Provider  without email.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY5}=  db.add_timezone_date  ${tz}   5
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY5}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${EMPTY} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   


JD-TC-Upload_ShoppingList_By_Provider-12
    [Documentation]   place an order by Provider  without phone number.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4
                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Ph_C15}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['phoneNumber']}  ${Ph_C15}  


JD-TC-Upload_ShoppingList_By_Provider-UH9
    [Documentation]    Place an order By Provider for Home Delivery a date other than in catalog schedule.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${OrderDate}=  db.add_timezone_date  ${tz}  35
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${OrderDate}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${DELIVERY_DATE_NOT_SUPPORTED}"
    

JD-TC-Upload_ShoppingList_By_Provider-UH10
    [Documentation]   place an order by Provider for a past date.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${OrderDate}=  db.subtract_timezone_date  ${tz}    2
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${OrderDate}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${DELIVERY_DATE_NOT_SUPPORTED}"


JD-TC-Upload_ShoppingList_By_Provider-UH11
    [Documentation]   place an order by Provider  without an order date.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4
                              
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${EMPTY}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${ORDER_DATE_NEEDED}"


JD-TC-Upload_ShoppingList_By_Provider-UH12
    [Documentation]   place an order by Provider  without any timings.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4
                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY4}    ${EMPTY}    ${EMPTY}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${TIME_SLOT_NEEDED}"
    


JD-TC-Upload_ShoppingList_By_Provider-UH13
    [Documentation]    Place an order By Provider using unavailable time slot           
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY9}=  db.add_timezone_date  ${tz}  9
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY9}    ${sTime1}    ${eTime2}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${TIME_SLOT_NEEDED}"



JD-TC-Upload_ShoppingList_By_Provider-UH14
    [Documentation]   place an order by Provider without enable order settings.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[1]}   Disable Order Settings

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4
                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY4}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"       "${ORDER_SETTINGS_NOT_ENABLED}"







