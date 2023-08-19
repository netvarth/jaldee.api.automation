*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
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

*** Test Cases ***
JD-TC-GetBillByUUid-1
    [Documentation]    Update Delivery Charge By provider for home delivery.check bill after order taxable and non taxable items.

    clear_queue    ${PUSERNAME123}
    clear_service  ${PUSERNAME123}
    clear_customer   ${PUSERNAME123}
    clear_Item   ${PUSERNAME123}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid3}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME123}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME120}.ynwtest@netvarth.com

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

    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime3}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Suite Variable    ${deliveryCharge3}

    ${NewCharge}=  Random Int  min=110   max=150
    ${NewdeliveryCharge}=  Convert To Number  ${NewCharge}  1
    Set Suite Variable    ${NewdeliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}

    ${catalogName}=   FakerLibrary.name  
    Set Suite Variable   ${catalogName}

    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable   ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable   ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Suite Variable   ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Suite Variable   ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable   ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable   ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable   ${homeDelivery}
    ${NewhomeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${NewdeliveryCharge}
    Set Suite Variable   ${NewhomeDelivery}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable   ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable   ${postInfo}
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

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}
    ${far}=  Random Int  min=14  max=18
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=2
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5
    
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
    # Set Suite Variable  ${address} 
    # ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    # ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    # Set Suite Variable  ${item_quantity1}
    # ${firstname}=  FakerLibrary.first_name
    # Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200
    
    # ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Suite Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   city=${city}  countryCode=${countryCodes[0]}   firstName=${C_firstName}   lastName=${C_lastName}     landMark=${landMark}  phoneNumber=${CUSERPH}  address=${homeDeliveryAddress}   postalCode=${C_num1}   email=${C_email}   
    Set Suite Variable  ${address}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME20}    ${C_email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid3}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 

    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    Set Suite Variable   ${netTotal}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    Set Suite Variable   ${amountDue}

    ${resp}=  Get Bill By UUId  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid3}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid3}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}
    Set Suite Variable   ${total1}

    ${resp}=  Get Bill By UUId  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid3}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid3}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date   13
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid3}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid3}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 

    resetsystem_time


JD-TC-GetBillByUUid-2
    [Documentation]    Generate bill in history. only after the date of order

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY10}=  db.add_timezone_date  ${tz}   10
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY10}    ${CUSERNAME20}    ${C_email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid4}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid4}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid4}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 

    change_system_date   13

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid4}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid4}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    resetsystem_time



JD-TC-GetBillByUUid-3
    [Documentation]    update catalog after the date of order. And generate bill before the date of Order_delivery

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY5}=  db.add_timezone_date  ${tz}   5
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY5}    ${CUSERNAME20}    ${C_email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid5}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid5}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid5} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid5}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    
    change_system_date   1

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Catalog For ShoppingCart   ${CatalogId3}  ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${NewhomeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    change_system_date   7

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid5}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid5}  ${pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    resetsystem_time

