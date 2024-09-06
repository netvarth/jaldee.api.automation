*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ORDER ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***

${self}    0
${itemName1}   item1Name101
${itemName2}   item2Name102
${itemName3}   item3Name103
${itemName4}   item4Name104

${itemCode1}   item1Code101
${itemCode2}   item2Code102
${itemCode3}   item3Code103
${itemCode4}   item4Code104


*** Test Cases ***

JD-TC-Update_Catalog_For_ShoppingCart-1
    [Documentation]  Provider Create catalog for ShoppingCart and Update it
    clear_Item  ${PUSERNAME130}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    
    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${shortDesc1}   
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Suite Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300 
    Set Suite Variable  ${price1}
    ${price1float}=  twodigitfloat  ${price1}
    Set Suite Variable  ${price1float}
    ${price2float}=   Convert To Number   ${price1}  2
    Set Suite Variable  ${price2float}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal1}  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1}
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Suite Variable  ${promoPrice1float}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}  

    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}
    
    ${itemName1}=   FakerLibrary.word 
    Set Suite Variable  ${itemName1}
    
    ${itemName2}=   FakerLibrary.name 
    Set Suite Variable  ${itemName2}

    ${itemCode1}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode1}

    ${itemCode2}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode2}

    ${itemName3}=   FakerLibrary.word 
    Set Suite Variable  ${itemName3}
    
    ${itemName4}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemName4}

    ${itemCode3}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode3}

    ${itemCode4}=   FakerLibrary.lastname 
    Set Suite Variable  ${itemCode4}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[0]}   isStockAvailable=${bool[0]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[0]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${resp}=   Get Item By Id  ${item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate}

    # ${noOfOccurance}=  Random Int  min=0   max=10
    # Set Suite Variable  ${noOfOccurance}

    Set Suite Variable  ${noOfOccurance}   0
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge}
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title} 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text}
    ${minQuantity}=  Random Int  min=1   max=3
    Set Suite Variable  ${minQuantity}
    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable  ${maxQuantity}

    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc} 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy} 

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    # -----------------------
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    # -----------------------
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    Set Suite Variable  ${homeDelivery}
    # -----------------------
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    # -----------------------
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    # -----------------------
    ${Statuses_list1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Statuses_list1}
    # -----------------------
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${Item1_list}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${Item2_list}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${Item1_list}   ${Item2_list}
    Set Suite Variable  ${catalogItem}
    # -----------------------
    

    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}
    ${far}=  Random Int  min=10   max=20
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=1   max=3
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${EMPTY}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${startDate2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${startDate2}
    ${endDate2}=  db.add_timezone_date  ${tz}  45      
    Set Suite Variable  ${endDate2}
    ${sTime2}=  add_timezone_time  ${tz}  0  10  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  0  50  
    Set Suite Variable   ${eTime2}
    ${list2}=  Create List  1  2  3  4  5  6  
    Set Suite Variable  ${list2}
    ${deliveryCharge2}=  Random Int  min=50   max=1000
    Set Suite Variable  ${deliveryCharge2}
    ${Title2}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title2} 
    ${Text2}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text2}
    ${minQuantity2}=  Random Int  min=1   max=3
    Set Suite Variable  ${minQuantity2}
    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable  ${maxQuantity2}
    ${catalogDesc2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc2} 
    ${cancelationPolicy2}=  FakerLibrary.Sentence   nb_words=6
    Set Suite Variable  ${cancelationPolicy2} 

    ${terminator2}=  Create Dictionary  endDate=${endDate2}  noOfOccurance=${noOfOccurance}
    ${timeSlot2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots2}=  Create List  ${timeSlot2}
    ${catalogSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list2}  startDate=${startDate2}   terminator=${terminator2}   timeSlots=${timeSlots2}
    Set Suite Variable  ${catalogSchedule2}
    # -----------------------
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp2}
    # -----------------------
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}
    Set Suite Variable  ${homeDelivery2}
    # -----------------------
    ${preInfo2}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title2}   preInfoText=${Text2}   
    Set Suite Variable  ${preInfo2}
    # -----------------------
    ${postInfo2}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title2}   postInfoText=${Text2}   
    Set Suite Variable  ${postInfo2}
    # -----------------------
    ${Statuses_list2}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Statuses_list2}
    # -----------------------
    ${item3_Id}=  Create Dictionary  itemId=${item_id3}
    ${Item3_list}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    Set Suite Variable  ${Item3_list}
    ${item4_Id}=  Create Dictionary  itemId=${item_id4}
    ${Item4_list}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    Set Suite Variable  ${Item4_list}
    
    ${catalogItem2}=  Create List   ${Item3_list}   ${Item4_list}
    Set Suite Variable  ${catalogItem2}
    # -----------------------
    ${advanceAmount2}=  Random Int  min=15   max=1000
    Set Suite Variable  ${advanceAmount2}
    
    ${catalogName5}=   FakerLibrary.lastname 
    Set Suite Variable  ${catalogName5}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId1}  ${catalogName5}  ${catalogDesc2}   ${catalogSchedule2}   ${orderType1}   ${paymentType}   ${Statuses_list2}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${resp}=  Update Catalog For ShoppingCart   ${CatalogId1}  ${catalogName5}  ${catalogDesc2}   ${catalogSchedule2}   ${orderType1}   ${paymentType}   ${Statuses_list2}   ${Empty_list}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-Update_Catalog_For_ShoppingCart-2
    [Documentation]  Consumer place order for Home_Delivery after that Provider Update catalog
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    ${accId}=  get_acc_id  ${PUSERNAME130}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings
    
    ${catalogName3}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName3}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Suite Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}   10
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
    
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${far_update}=  Random Int  min=${soon+1}   max=8
    
    ${catalogName4}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName4}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far_update}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Contact_Number}=  Evaluate  ${CUSERNAME20}+11111111
    Set Test Variable  ${NEW_email}  ${firstname}${Contact_Number}.${test_mail}

    ${resp}=   Update Order For HomeDelivery   ${orderid1}  ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${Contact_Number}    ${NEW_email}   ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Update_Catalog_For_ShoppingCart-3
    [Documentation]  Consumer place order for Home_Delivery after that Provider Update catalog and provider try to update existing order details.
    # clear_Catalog   ${PUSERNAME130}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    ${accId}=  get_acc_id  ${PUSERNAME130}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    Set Test Variable  ${HowSoon}    0
    Set Test Variable  ${HowFar}     20
    ${startDate4}=  db.get_date_by_timezone  ${tz}
    ${endDate4}=  db.add_timezone_date  ${tz}  45    
    ${sTime4}=  add_timezone_time  ${tz}  0  10  
    ${eTime4}=  add_timezone_time  ${tz}  0  30  
    ${terminator4}=  Create Dictionary  endDate=${endDate4}  noOfOccurance=${noOfOccurance}
    ${timeSlot4}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots4}=  Create List  ${timeSlot4}
    ${catalogSchedule4}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate4}   terminator=${terminator4}   timeSlots=${timeSlots4}
    ${pickUp4}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery4}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule4}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp4}   homeDelivery=${homeDelivery4}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${HowFar}   howSoon=${HowSoon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Test Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}      10
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
    
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Test Variable  ${EMPTY_List}
    ${O_sTime1}=  add_timezone_time  ${tz}  0  25  
    ${O_eTime1}=  add_timezone_time  ${tz}   0  35

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime4}    ${eTime4}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${far_update}=  Random Int  min=${soon+1}   max=8
  

    ${startDate5}=  db.add_timezone_date  ${tz}  1  
    ${endDate5}=  db.add_timezone_date  ${tz}  45    
    ${sTime5}=  add_timezone_time  ${tz}  0  20  
    ${eTime5}=  add_timezone_time  ${tz}  0  50  
    ${terminator5}=  Create Dictionary  endDate=${endDate5}  noOfOccurance=${noOfOccurance}
    ${timeSlot5}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots5}=  Create List  ${timeSlot5}
    ${catalogSchedule5}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate5}   terminator=${terminator5}   timeSlots=${timeSlots5}
    ${pickUp5}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery5}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule5}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}
    
    ${catalogName10}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName10}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName10}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp5}   homeDelivery=${homeDelivery5}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far_update}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Contact_Number}=  Evaluate  ${CUSERNAME20}+11111111
    Set Test Variable  ${NEW_email}  ${firstname}${Contact_Number}.${test_mail}

    ${resp}=   Update Order For HomeDelivery   ${orderid1}  ${bool[1]}    ${address}    ${sTime5}    ${eTime5}   ${DAY1}    ${Contact_Number}    ${NEW_email}   ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update_Catalog_For_ShoppingCart-4
    [Documentation]  Consumer place order for Store_pickup after that Provider Update catalog and provider try to update existing order details.
    # clear_Catalog   ${PUSERNAME130}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    ${accId}=  get_acc_id  ${PUSERNAME130}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    Set Test Variable  ${HowSoon}    0
    Set Test Variable  ${HowFar}     20
    ${startDate4}=  db.get_date_by_timezone  ${tz}
    ${endDate4}=  db.add_timezone_date  ${tz}  45    
    ${sTime4}=  add_timezone_time  ${tz}   0  10
    ${eTime4}=  add_timezone_time  ${tz}  0  50  
    ${terminator4}=  Create Dictionary  endDate=${endDate4}  noOfOccurance=${noOfOccurance}
    ${timeSlot4}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots4}=  Create List  ${timeSlot4}
    ${catalogSchedule4}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate4}   terminator=${terminator4}   timeSlots=${timeSlots4}
    ${pickUp4}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule4}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery4}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule4}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}

    ${catalogName}=   FakerLibrary.name 

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule4}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp4}   homeDelivery=${homeDelivery4}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${HowFar}   howSoon=${HowSoon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Test Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 


    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  10  
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
    
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Test Variable  ${EMPTY_List}
    ${O_sTime1}=  add_timezone_time  ${tz}  0  20  
    ${O_eTime1}=  add_timezone_time  ${tz}  0  30  

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId}    ${self}    ${CatalogId3}   ${bool[1]}    ${O_sTime1}    ${O_eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${far_update}=  Random Int  min=${soon+1}   max=8
  

    ${startDate5}=  db.add_timezone_date  ${tz}  1  
    ${endDate5}=  db.add_timezone_date  ${tz}  45    
    ${sTime5}=  add_timezone_time  ${tz}   0  10
    ${eTime5}=  add_timezone_time  ${tz}  0  50  
    ${terminator5}=  Create Dictionary  endDate=${endDate5}  noOfOccurance=${noOfOccurance}
    ${timeSlot5}=  Create Dictionary  sTime=${sTime4}   eTime=${eTime4}
    ${timeSlots5}=  Create List  ${timeSlot5}
    ${catalogSchedule5}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate5}   terminator=${terminator5}   timeSlots=${timeSlots5}
    ${pickUp5}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule5}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery5}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule5}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}

    ${catalogName11}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName11}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName11}  ${catalogDesc}   ${catalogSchedule4}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp5}   homeDelivery=${homeDelivery5}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far_update}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Contact_Number}=  Evaluate  ${CUSERNAME20}+11111111
    Set Test Variable  ${NEW_email}  ${firstname}${Contact_Number}.${test_mail}

    ${resp}=   Update Order For HomeDelivery   ${orderid1}  ${bool[1]}    ${address}    ${O_sTime1}    ${O_eTime1}   ${DAY1}    ${Contact_Number}    ${NEW_email}   ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update Order For Pickup   ${orderid1}  ${bool[1]}    ${O_sTime1}    ${O_eTime1}   ${DAY1}    ${Contact_Number}    ${NEW_email}   ${countryCodes[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Update_Catalog_For_ShoppingCart-5
    [Documentation]  Provider Update catalog without change in Item_List
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName6}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName6}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName6}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Suite Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 


    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${far_update}=  Random Int  min=${soon+1}   max=8
    ${EMPTY_List}=  Create List
    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId5}  ${catalogName6}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${EMPTY_List}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far_update}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-Update_Catalog_For_ShoppingCart-UH1
    [Documentation]  Provider Update catalog without change in Item_List
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName7}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName7}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId7}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Suite Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 
    ${ITEMS_ARE_ALREADY_ADDED}=  Format String   ${ITEMS_ALREADY_ADDED}      Item ${item_id3},${item_id4}
    ${far_update}=  Random Int  min=${soon+1}   max=8
    ${EMPTY_List}=  Create List

    ${catalogName8}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName8}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId7}  ${catalogName8}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far_update}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEMS_ARE_ALREADY_ADDED}"


JD-TC-Update_Catalog_For_ShoppingCart-UH2
    [Documentation]  Provider Update catalog using already existing items
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Catalog    ${CatalogId7}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${ITEMS_ARE_ALREADY_ADDED}=  Format String   ${ITEMS_ALREADY_ADDED}    Item ${item_id3}
    ${catalogItemList1}=  Create List   ${Item3_list}
    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId7}  ${catalogName8}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEMS_ARE_ALREADY_ADDED}"

    ${ITEMS_ARE_ALREADY_ADDED}=  Format String   ${ITEMS_ALREADY_ADDED}      Item ${item_id3},${item_id4}
    ${catalogItemList2}=  Create List   ${Item3_list}   ${Item4_list}
    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId7}  ${catalogName8}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEMS_ARE_ALREADY_ADDED}"


JD-TC-Update_Catalog_For_ShoppingCart-UH3
    [Documentation]  Provider Create catalog for ShoppingCart and Another provider try to Update catalog
    ${resp}=  Encrypted Provider Login  ${PUSERNAME148}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-Update_Catalog_For_ShoppingCart-UH4
    [Documentation]   Update catalog Without login
    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    
JD-TC-Update_Catalog_For_ShoppingCart-UH5
    [Documentation]   Login as consumer and Update items in catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${Statuses_list1}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-Update_Catalog_For_ShoppingCart-6
    [Documentation]  Provider Create catalog for ShoppingCart and Update order_type as SHOPPING_LIST
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Update Catalog For ShoppingList   ${CatalogId1}   ${catalogName1}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()['catalogItem']}   ${EMPTY_List}



JD-TC-Update_Catalog_For_ShoppingCart-7
    [Documentation]  Update order_type from SHOPPING_LIST to SHOPPING_CART 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Update Catalog For ShoppingList   ${CatalogId1}   ${catalogName1}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()['catalogItem']}   ${EMPTY_List}

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId1}  ${catalogName1}  ${EMPTY}   ${catalogSchedule2}   ${orderType1}   ${paymentType}   ${Statuses_list2}   ${catalogItem2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    


