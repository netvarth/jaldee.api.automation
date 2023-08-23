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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/Keywords.robot



*** Variables ***
${self}    0


*** Test Cases ***

JD-TC-Get_Cart_Details-1

    [Documentation]    Get order details without create a coupon.

    clear_queue    ${PUSERNAME59}
    clear_service  ${PUSERNAME59}
    clear_customer   ${PUSERNAME59}
    clear_Item   ${PUSERNAME59}
    clear_Coupon   ${PUSERNAME59}
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
    
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${shortDesc1} 
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Suite Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300  
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}
    Set Suite Variable  ${price1float} 

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    Set Suite Variable  ${itemNameInLocal1} 
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    Set Suite Variable  ${promoPrice1float} 
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1} 
    ${note1}=  FakerLibrary.Sentence   
    Set Suite Variable  ${note1} 
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1} 

    ${itemName3}=   FakerLibrary.word 
    Set Suite Variable  ${itemName3}
    
    ${itemName4}=   FakerLibrary.name 
    Set Suite Variable  ${itemName4}

    ${itemCode3}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode3}

    ${itemCode4}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode4}
    
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}  

    ${displayName4}=   FakerLibrary.word 
    Set Suite Variable  ${displayName4}  

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate} 
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate} 

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate1} 
    ${endDate1}=  db.add_timezone_date  ${tz}  15        
    Set Suite Variable  ${endDate1} 

    ${noOfOccurance}=  Random Int  min=0   max=0
    Set Suite Variable  ${noOfOccurance} 

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  15   
    Set Suite Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  0  17
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable    ${eTime2}


    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 

    ${Del_Charge1}=  Random Int  min=50   max=100
    Set Suite Variable    ${Del_Charge1}
    ${deliveryCharge1}=  Convert To Number  ${Del_Charge1}  1
    Set Suite Variable    ${deliveryCharge1}


    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title} 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text} 

    ${minQuantity1}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity1}

    ${maxQuantity1}=  Random Int  min=${minQuantity1}   max=50
    Set Suite Variable   ${maxQuantity1}


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
    Set Suite Variable  ${timeSlots} 
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}
    Set Suite Variable  ${pickupSchedule} 
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge1}
    Set Suite Variable  ${homeDelivery}
    
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
   
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${ItemList1}
    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
    Set Suite Variable  ${advanceAmount} 

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

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${ItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    # ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${item3_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item3_total}=  Convert To twodigitfloat  ${item3_total}
    ${item4_price}=  Evaluate  ${price1} * ${promotionalPrcnt1} / 100
    ${item4_price}=  Evaluate  ${price1} - ${item4_price}
    ${item4_price}=  twodigitfloat  ${item4_price}
    ${item4_price}=  Evaluate  ${item4_price} * 1
    # ${item4_price}=  Convert To Number  ${item4_price}  1

    ${item4_total}=  Evaluate  ${item_quantity1} * ${item4_price} 
    ${item4_total}=  Convert To twodigitfloat  ${item4_total}

    ${netTotal}=  Evaluate  ${item3_total} + ${item4_total}
    ${netItemQuantity}=  Evaluate  ${item_quantity1} + ${item_quantity1}

    ${cartAmount}=  Evaluate  ${item3_total} + ${item4_total} + ${Del_Charge1}
    # ${cartAmount}=  twodigitfloat  ${cartAmount}  
    ${totalTaxAmount}=  Evaluate  ${item4_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${Del_Charge1}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response  ${resp}  id=${CatalogId1}  catalogName=${catalogName1}  catalogDesc=${catalogDesc}   orderType=${orderType1}   orderStatuses=${orderStatus_list}   minNumberItem=${minNumberItem}    maxNumberItem=${maxNumberItem}  cancellationPolicy=${cancelationPolicy}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${promoPrice1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item3_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[0]}

    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['id']}         ${item_id4}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['name']}       ${displayName4}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['quantity']}   ${item_quantity1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['price']}      ${item4_price}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['totalPrice']}   ${item4_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}      ${amountDue}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}    0.0
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}      0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}    0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}     0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}         ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}    ${deliveryCharge1}



JD-TC-Get_Cart_Details-2
    [Documentation]    Get order details when order needs Advance amount (Advance amount less than item total price).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=200   max=500 
    ${price2}=  Convert To Number  ${price2}  1
    Set Suite Variable  ${price2}

    ${price2float}=  twodigitfloat  ${price2}
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice2}=  Random Int  min=150   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Suite Variable  ${promoPrice2}

    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt2}=   Evaluate    random.uniform(70.0,90)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    Set Suite Variable  ${promotionalPrcnt2}

    ${note2}=  FakerLibrary.Sentence   

    ${promoLabel2}=   FakerLibrary.word 

    ${itemName1}=   FakerLibrary.word 
    Set Suite Variable  ${itemName1}
    
    ${itemName2}=   FakerLibrary.name 
    Set Suite Variable  ${itemName2}

    ${itemCode1}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode1}

    ${itemCode2}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode2}
    
    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}  

    ${displayName2}=   FakerLibrary.last_name 
    Set Suite Variable  ${displayName2}  

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[0]}    ${itemName1}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}


    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[1]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[2]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${startDate2}=  db.get_date_by_timezone  ${tz}
    ${endDate2}=  db.add_timezone_date  ${tz}  13      
  
    ${Del_Charge2}=  Random Int  min=50   max=100
    Set Suite Variable    ${Del_Charge2}
    ${deliveryCharge2}=  Convert To Number  ${Del_Charge2}  1
    Set Suite Variable    ${deliveryCharge2}

    ${deliveryCharge3}=  Evaluate  ${deliveryCharge2} + 10
    Set Suite Variable    ${deliveryCharge3}

    ${minQuantity2}=  Random Int  min=1   max=3
    Set Suite Variable   ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=6   max=20
    Set Suite Variable   ${maxQuantity2}

    ${item3_Id}=  Create Dictionary  itemId=${item_id1}
    ${item4_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=1   maxQuantity=${maxQuantity2}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=1   maxQuantity=${maxQuantity2}  
    ${ItemList2}=  Create List   ${catalogItem3}  ${catalogItem4}
    Set Suite Variable  ${ItemList2}
    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[1]}

    # ${Adv_Amount2}=  Random Int  min=55   max=100
    ${index}=  Random Int  min=200   max=500
    ${Adv_Amount2}=  Evaluate  ${promoPrice2} + ${Del_Charge2} + ${index}
    ${advanceAmount2}=  Convert To Number  ${Adv_Amount2}  1
    Set Suite Variable    ${advanceAmount2}
    ${catalogSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule2}
    ${pickupSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}
    Set Suite Variable  ${pickupSchedule2} 
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule2}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp2}
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}
    Set Suite Variable  ${homeDelivery2}
    ${homeDelivery3}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery3}
    
    ${catalogName3}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName3}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule2}   ${orderType1}   ${paymentType1}   ${StatusList1}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    
    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

  
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity2}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${item1_total}=  Evaluate  ${item_quantity2} * ${promoPrice2}
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${item4_price}=  Evaluate  ${price2} * ${promotionalPrcnt2} / 100
    ${item4_price}=  Evaluate  ${price2} - ${item4_price}
    ${item4_price}=  twodigitfloat  ${item4_price}
    ${item4_price}=  Evaluate  ${item4_price} * 1
    # ${item4_price}=  Convert To Number  ${item4_price}  1

    ${item2_total}=  Evaluate  ${item_quantity2} * ${item4_price} 
    ${item2_total}=  Convert To twodigitfloat  ${item2_total}
    ${netTotal}=  Evaluate  ${item1_total} + ${item2_total}
    ${netItemQuantity}=  Evaluate  ${item_quantity2} + ${item_quantity2}

    ${cartAmount}=  Evaluate  ${item1_total} + ${item2_total} + ${Del_Charge2}
    # ${cartAmount}=  twodigitfloat  ${cartAmount}  
    ${totalTaxAmount}=  Evaluate  ${item2_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${Del_Charge2}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity2}  ${item_id2}   ${item_quantity2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response  ${resp}  id=${CatalogId1}  catalogName=${catalogName1}  catalogDesc=${catalogDesc}   orderType=${orderType1}   orderStatuses=${orderStatus_list}   minNumberItem=${minNumberItem}    maxNumberItem=${maxNumberItem}  cancellationPolicy=${cancelationPolicy}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${promoPrice2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[0]}

    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['id']}         ${item_id2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['name']}       ${displayName2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['quantity']}   ${item_quantity2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['price']}      ${item4_price}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['totalPrice']}   ${item2_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][1]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}      ${amountDue}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}    ${advanceAmount2}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}      0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}    0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}     0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}         ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}    ${deliveryCharge2}



JD-TC-Get_Cart_Details-3
    [Documentation]    Get order details when order needs Advance amount (Advance amount greater than item total price).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   1
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${item1_total}=  Evaluate  ${promoPrice2} * 1
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response  ${resp}  id=${CatalogId1}  catalogName=${catalogName1}  catalogDesc=${catalogDesc}   orderType=${orderType1}   orderStatuses=${orderStatus_list}   minNumberItem=${minNumberItem}    maxNumberItem=${maxNumberItem}  cancellationPolicy=${cancelationPolicy}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${promoPrice2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item1_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[0]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}      ${item1_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}    ${item1_total}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}      0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}    0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}     0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}         0.0
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}    0.0


    ${item2_price}=  Evaluate  ${price2} * ${promotionalPrcnt2} / 100
    ${item2_price}=  Evaluate  ${price2} - ${item2_price}
    ${item2_price}=  twodigitfloat  ${item2_price}
    ${item2_price}=  Evaluate  ${item2_price} * 1

    ${item2_total}=  Evaluate  ${item2_price} * 1
    ${totalTaxAmount}=  Evaluate  ${item2_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${item2_total}=  Evaluate  ${item2_total} + ${Del_Charge2} + ${totalTaxAmount}
    ${item2_total}=  Convert To twodigitfloat  ${item2_total}

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id2}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response  ${resp}  id=${CatalogId1}  catalogName=${catalogName1}  catalogDesc=${catalogDesc}   orderType=${orderType1}   orderStatuses=${orderStatus_list}   minNumberItem=${minNumberItem}    maxNumberItem=${maxNumberItem}  cancellationPolicy=${cancelationPolicy}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${item2_price}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item2_price}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[1]}

    Should Be Equal As Strings   ${resp.json()['netTotal']}      ${item2_total}
    Should Be Equal As Strings   ${resp.json()['advanceAmount']}    ${item2_total}
    Should Be Equal As Strings   ${resp.json()['jdnDiscount']}      0.0
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}    0.0
    Should Be Equal As Strings   ${resp.json()['totalDiscount']}     0.0
    Should Be Equal As Strings   ${resp.json()['taxAmount']}         ${totalTaxAmount}
    Should Be Equal As Strings   ${resp.json()['deliveryCharge']}    ${deliveryCharge2}


JD-TC-Get_Cart_Details-4
    [Documentation]    Get order details by applying a coupon.(Coupon type with amount and percentage applied)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${domain}  ${decrypted_data['sector']}
    Set Suite Variable  ${subdomain}  ${decrypted_data['subSector']}
    
    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  17
    Set Suite Variable  ${DAY2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    # -------------------------------------------------------------
    
    ${cupn_code2018_2}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018_2}
    ${cupn_name2}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name2}
    clear_jaldeecoupon  ${cupn_code2018_2}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018_2}  ${cupn_name2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018_2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    # -------------------------------------------------------------


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018_2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018_2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   1
    ${Coupon1_list}=  Create List   ${cupn_code2018}   ${cupn_code2018_2}
    Set Suite Variable  ${EMPTY_List}

    ${item1_total}=  Evaluate  ${promoPrice2} * 1
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${item4_price}=  Evaluate  ${price2} * ${promotionalPrcnt2} / 100
    ${item4_price}=  Evaluate  ${price2} - ${item4_price}
    ${item4_price}=  twodigitfloat  ${item4_price}
    ${item4_price}=  Evaluate  ${item4_price} * 1
    # ${item4_price}=  Convert To Number  ${item4_price}  1

    ${item2_total}=  Evaluate  ${item4_price} * 1
    ${item2_total}=  Convert To twodigitfloat  ${item2_total}
    ${netTotal}=  Evaluate  ${item1_total} + ${item2_total}
    ${netItemQuantity}=  Evaluate  ${item_quantity2} + ${item_quantity2}

    ${cartAmount}=  Evaluate  ${item1_total} + ${item2_total} + ${Del_Charge2}
    # ${cartAmount}=  twodigitfloat  ${cartAmount}  
    ${totalTaxAmount}=  Evaluate  ${item2_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${Del_Charge2}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon1_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   1
    ${Coupon2_list}=  Create List   ${cupn_code2018_2}  ${cupn_code2018}   

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon2_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200





JD-TC-Get_Cart_Details-UH1

    [Documentation]    Get order details by applying a coupon.(Coupon type with amount and percentage applied when combineWithOtherCoupon is false)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${domain}  ${decrypted_data['sector']}
    Set Suite Variable  ${subdomain}  ${decrypted_data['subSector']}

    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  17
    Set Suite Variable  ${DAY2}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018_3}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018_3}
    ${cupn_name3}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name3}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code2018_3}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018_3}  ${cupn_name3}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018_3}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018_3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    # -------------------------------------------------------------
    
    ${cupn_code2018_4}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018_4}
    ${cupn_name4}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name4}
    clear_jaldeecoupon  ${cupn_code2018_4}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018_4}  ${cupn_name4}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018_4}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    # -------------------------------------------------------------


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018_3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018_3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018_4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   3
    ${item3_total}=  Evaluate  ${item_quantity3} * ${promoPrice2}
    ${item3_total}=  Convert To twodigitfloat  ${item3_total}
    ${Coupon3_list}=  Create List   ${cupn_code2018_3}   ${cupn_code2018_4}


    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon3_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${promoPrice2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item3_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[0]}
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}        50.0
    Should Be Equal As Strings   ${resp.json()['providerCouponDiscount']}      0.0


    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   5
    ${item3_total}=  Evaluate  ${item_quantity3} * ${promoPrice2}
    ${item3_total}=  Convert To twodigitfloat  ${item3_total}
    ${Coupon4_list}=  Create List   ${cupn_code2018_4}  ${cupn_code2018_3}   

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon4_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['id']}         ${item_id1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['name']}       ${displayName1}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['quantity']}   ${item_quantity3}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['price']}      ${promoPrice2}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['status']}     FULFILLED
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['totalPrice']}   ${item3_total}
    Should Be Equal As Strings   ${resp.json()['orderItems'][0]['taxable']}      ${bool[0]}
    Should Be Equal As Strings   ${resp.json()['jaldeeCouponDiscount']}        100.0
    Should Be Equal As Strings   ${resp.json()['providerCouponDiscount']}      0.0
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  "${resp.json()}"  "${cupn_code2018_3} ${JALDEE_COUPON_CANT_COMBINE_WITH_OTHER}"


JD-TC-Get_Cart_Details-UH2
    [Documentation]    Get cart details by applying a coupon.(If Coupon start date is a future date)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${domain}  ${decrypted_data['sector']}
    Set Suite Variable  ${subdomain}  ${decrypted_data['subSector']}

    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  18
    Set Suite Variable  ${DAY2}
    ${DAY3}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${DAY3}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018_7}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018_7}
    ${cupn_name7}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name7}
    clear_jaldeecoupon  ${cupn_code2018_7}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018_7}  ${cupn_name7}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018_7}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018_7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    # -------------------------------------------------------------
    
    ${cupn_code2018_8}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018_8}
    ${cupn_name8}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name8}
    clear_jaldeecoupon  ${cupn_code2018_8}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018_8}  ${cupn_name8}  ${cupn_des}  ${age_group[0]}  ${DAY3}  ${DAY2}  ${discountType[1]}  10  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018_8}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018_8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    # -------------------------------------------------------------


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018_7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018_7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018_8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018_8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   3
    ${Coupon3_list}=  Create List   ${cupn_code2018_7}   ${cupn_code2018_8}


    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon3_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity3}   5
    ${Coupon4_list}=  Create List   ${cupn_code2018_8}  ${cupn_code2018_7}   

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon4_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  "${resp.json()}"   "Coupon not applicable : Order date is before than coupon starting date."



JD-TC-Get_Cart_Details-5
    [Documentation]    Enable JDN and Get cart details 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${disc_max}=   Random Int   min=100   max=300
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3}  

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${EMPTY_List}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    



JD-TC-Get_Cart_Details-6
    [Documentation]    Get cart details by applying a coupon and JDN
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3}  
    ${Coupon9_list}=  Create List   ${cupn_code2018_7} 

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[0]}   ${DAY1}    ${Coupon9_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    




JD-TC-Get_Cart_Details-7
    [Documentation]    Update JDN percentage to change delivery charge and Get cart details after that
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${disc_max2}=   Random Int   min=200   max=300
    ${disc_max2}=  Convert To Number   ${disc_max2}
    ${d_note2}=   FakerLibrary.word

    ${resp}=   Update JDN with Percentage    ${d_note2}  ${jdn_disc_percentage[1]}   ${disc_max2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3}  
    ${Coupon9_list}=  Create List   ${cupn_code2018_7} 

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[1]}   ${DAY1}    ${Coupon9_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Get_Cart_Details-8
    [Documentation]    Update catalog to change delivery charge and Get cart details after that
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${EMPTY_List}=  Create List
    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName3}  ${catalogDesc}   ${catalogSchedule2}   ${orderType1}   ${paymentType1}   ${StatusList1}   ${EMPTY_List}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery3}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3}  
    ${Coupon9_list}=  Create List   ${cupn_code2018_7} 

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[1]}   ${DAY1}    ${Coupon9_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get_Cart_Details-9
    [Documentation]    Get cart details when disabled JDN
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3} 
    ${Coupon9_list}=  Create List   ${cupn_code2018_7} 

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId3}   ${boolean[1]}   ${DAY1}    ${Coupon9_list}    ${item_id1}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get_Cart_Details-10
    [Documentation]    Get cart details when payment type is FULLAMOUNT
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[2]}
    
    ${catalogName4}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName4}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule2}   ${orderType1}   ${paymentType2}   ${StatusList1}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${disc_max}=   Random Int   min=100   max=300
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity3}=  Random Int  min=${minQuantity2}   max=${maxQuantity2}
    Set Suite Variable  ${item_quantity3}  
    ${Coupon9_list}=  Create List   ${cupn_code2018_7} 

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId4}   ${boolean[1]}   ${DAY1}    ${Coupon9_list}    ${item_id1}   ${item_quantity3}   ${item_id2}   ${item_quantity3}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Get_Cart_Details-11
    [Documentation]    Get order details and Order items when advance_payment_type is FULLAMOUNT.(JDN Enabled and Jaldee coupon applied by consumer)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${domain}  ${decrypted_data['sector']}
    Set Suite Variable  ${subdomain}  ${decrypted_data['subSector']}

    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  20
    Set Suite Variable  ${DAY2}


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code1}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code1}
    ${cupn_name_C1}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name_C1}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code1}

    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name_C1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    # -------------------------------------------------------------
    
    ${cupn_code2}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2}
    ${cupn_name_C2}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name_C2}
    clear_jaldeecoupon  ${cupn_code2}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name_C2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  300  ${bool[0]}  ${bool[0]}  100  100  1000  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    # -------------------------------------------------------------


    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

   

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${item_quantity5}   5
    ${Coupon1_list}=  Create List   ${cupn_code1}   ${cupn_code2}
    

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId4}   ${boolean[1]}   ${DAY1}    ${Coupon1_list}    ${item_id1}   ${item_quantity5}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  12  
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

    
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME27}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME27}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId4}     ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY2}    ${CUSERNAME27}    ${email}  ${countryCodes[1]}  ${Coupon1_list}  ${item_id1}    ${item_quantity5}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}
    Set Suite Variable  ${prepayAmt}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item_one}=  Evaluate  ${item_quantity5} * ${promoPrice2}
    ${item_one}=  Convert To twodigitfloat  ${item_one} 

    ${jdnamt}=  Evaluate  ${item_one} * ${jdn_disc_percentage[0]} / 100
    ${jdnamt}=  Convert To twodigitfloat  ${jdnamt} 
    ${JDNTotal1}=  Evaluate  ${item_one} - ${jdnamt}
    ${coupon1}=  Evaluate  ${JDNTotal1} - 50
    ${coupon2}=  Evaluate  ${coupon1} * 10 / 100
    # ${coupon2}=  Convert To twodigitfloat  ${coupon2}
    ${totalDiscount}=  Evaluate  ${jdnamt} + 50 + ${coupon2}
    ${totalDiscount}=  Convert To twodigitfloat  ${totalDiscount}
    ${netTotal}=  Evaluate  ${item_one} + ${Del_Charge2} - ${totalDiscount}
    ${netTotal}=  Convert To twodigitfloat  ${netTotal}
    ${AmountDue}=  Evaluate  ${netTotal} - ${prepayAmt}
    ${AmountDue}=  Convert To twodigitfloat  ${AmountDue}

    ${cid8}=  get_id  ${CUSERNAME27}
    Set Suite Variable   ${cid8}

    ${resp}=  Make payment Consumer Mock  ${pid1}  ${prepayAmt}  ${purpose[0]}  ${orderid2}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s
    ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${netTotal}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${netTotal}  amountDue=0.0    totalTaxAmount=0.0

    sleep   1s
    ${resp}=   Get Order By Id   ${accId3}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Get_Cart_Details-UH3
    [Documentation]    Get order details using Invalid coupon code.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${INVALID_Coupon}=  Create List   0
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${INVALID_Coupon}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_INVALID}"


JD-TC-Get_Cart_Details-UH4
    [Documentation]    Get order details without login.

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    
JD-TC-Get_Cart_Details-UH5
    [Documentation]    Get order details by using provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"

    

JD-TC-Get_Cart_Details-UH6
    [Documentation]    Get order details using details of Shopping list.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId1}   ${boolean[1]}   ${DAY12}    ${EMPTY_List}    0    3
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings   ${resp.json()}   ${SHOPPINGLIST_NOT_SUPPORTED}


JD-TC-Get_Cart_Details-UH7
    [Documentation]    Get order details using Invalid shopping cart id.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    ${accId3}   0   ${boolean[1]}   ${DAY12}    ${EMPTY_List}    ${item_id3}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_CATALOG_FOUND}"





JD-TC-Get_Cart_Details-UH8
    [Documentation]    Get order details using Items not present in any available catalog.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY12}    ${EMPTY_List}    0   3
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ITEM_ID}"




JD-TC-Get_Cart_Details-UH9
    [Documentation]    Get order details using Invalid account id.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${resp}=   Get Cart Details    0   ${CatalogId2}   ${boolean[1]}   ${DAY12}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"





