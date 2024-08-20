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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${item1}   ITEM1
${item2}   ITEM2
${item3}   ITEM3
${item4}   ITEM4
${item5}   ITEM5
${self}    0
${digits}       0123456789
${discount}        Disc11
${coupon}          wheat

${catalogName}    catalog1_Name1111
${catalogName2}    catalog1_Name2222
${catalogName3}    catalog1_Name3333

*** Test Cases ***

JD-TC-CancelOrderByConsumer-1
    [Documentation]     Cancel Order for home delivery by consumer before bill payment

    clear_queue    ${PUSERNAME179}
    clear_service  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_Item   ${PUSERNAME179}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME179}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
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

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

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

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   city=${city}  countryCode=${countryCodes[0]}   firstName=${C_firstName}   lastName=${C_lastName}     landMark=${landMark}  phoneNumber=${CUSERPH}  address=${homeDeliveryAddress}   postalCode=${C_num1}   email=${C_email}   
    Set Test Variable  ${address}

    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME28}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId3}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME28}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Bill By UUId  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   New

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
    ${resp}=   Get Order By Id    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   Cancel



JD-TC-CancelOrderByConsumer-2
    [Documentation]     Cancel Order for home delivery by consumer after bill payment

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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

    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity2}=  Convert To Number  ${item_quantity2}  1
    Set Suite Variable  ${item_quantity2}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME8}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY2}    ${CUSERNAME8}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity2}  ${item_id4}    ${item_quantity2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
  
    ${resp}=   Get Order by uid    ${orderid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                                 ${orderid2}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}                        ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}                         ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['phoneNumber']}  ${CUSERPH}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['firstName']}    ${C_firstName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['lastName']}     ${C_lastName}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['email']}        ${C_email}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['address']}      ${homeDeliveryAddress}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['city']}         ${city}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['postalCode']}   ${C_num1}
    Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['landMark']}     ${landMark}
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']['countryCode']}  ${code}
   
    ${item_one}=  Evaluate  ${item_quantity2} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity2} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    ${amountDue}=  twodigitfloat  ${amountDue}  
    Set Suite Variable   ${amountDue}

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0   deliveryCharges=${deliveryCharge3}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}         ${amountDue} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid2}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}
    Set Suite Variable   ${total1}

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0   deliveryCharges=${deliveryCharge0}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}         ${total1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME8}
    Set Suite Variable   ${cid8}
    
    ${resp}=  Make payment Consumer Mock  ${accId3}  ${total1}  ${purpose[1]}  ${orderid2}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}    billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${total1}  amountDue=0.0    totalTaxAmount=${totalTaxAmount}
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${total1}
    sleep   1s
   
    ${resp}=   Get Order By Id   ${accId3}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=   Get Order By Id    ${accId3}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}          Cancel
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   Refund
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}     ${total1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}           -${total1}



JD-TC-CancelOrderByConsumer-3
    [Documentation]     Cancel Order for home delivery by consumer before advance payment
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}
    ${advanceAmount2}=  Random Int  min=500   max=1500
    Set Suite Variable  ${advanceAmount2}
    ${cancelationPolicy2}=  FakerLibrary.Sentence   nb_words=6
    Set Suite Variable  ${cancelationPolicy2}
   
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME28}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME28}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderInternalStatus']}   PREPAYMENTPENDING

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  01s
    ${resp}=   Get Order By Id    ${accId3}   ${orderid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled


JD-TC-CancelOrderByConsumer-4
    [Documentation]     Cancel Order for home delivery by consumer after Advance payment

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}  12  
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY2}    ${CUSERNAME8}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity2}  ${item_id4}    ${item_quantity2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${AdvncAmount}  ${resp.json()['advanceAmountToPay']}

    ${cid8}=  get_id  ${CUSERNAME8}
    Set Suite Variable   ${cid8}

    sleep   02s
    ${resp}=  Make payment Consumer Mock  ${accId3}  ${AdvncAmount}  ${purpose[0]}  ${orderid4}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer2}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref2}   ${resp.json()['paymentRefId']}

    sleep   02s
    ${resp}=   Get Order By Id   ${accId3}  ${orderid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DueAmount2}=  Evaluate  ${amountDue} - ${AdvncAmount}
    ${DueAmount2}=  Convert To twodigitfloat  ${DueAmount2}

    ${resp}=  Get Bill By UUId  ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   New
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}     ${AdvncAmount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}           ${DueAmount2}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
    ${resp}=   Get Order By Id    ${accId3}   ${orderid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Get Bill By UUId  ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   Cancel
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   Refund
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}     ${AdvncAmount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}           -${AdvncAmount}



JD-TC-CancelOrderByConsumer-UH1
    [Documentation]     Cancel Order for home delivery without login
    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-CancelOrderByConsumer-UH2
    [Documentation]     Cancel Order for home delivery using invalid order_id
    ${INVALID_OrderId}=  Random Int  min=50000  max=99999
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${INVALID_OrderId}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_NOT_FOUND}"


JD-TC-CancelOrderByConsumer-UH3
    [Documentation]     Cancel Order for home delivery using invalid Provider_id
    ${INVALID_ProviderId}=  Random Int  min=500000  max=999999
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${INVALID_ProviderId}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"


JD-TC-CancelOrderByConsumer-UH4
    [Documentation]     Again Cancel Order for home delivery by consumer
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ORDER_ALREADY_CANCELLED}=  Format String   ${STATE_ALREADY_CHANGED}    Cancelled
    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_ALREADY_CANCELLED}"


JD-TC-CancelOrderByConsumer-UH5
    [Documentation]     Cancel Order for home delivery by provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-CancelOrderByConsumer-UH6
    [Documentation]     Cancel Order for home delivery by Another consumer 

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Cancel Order By Consumer    ${accId3}   ${orderid12}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

 

