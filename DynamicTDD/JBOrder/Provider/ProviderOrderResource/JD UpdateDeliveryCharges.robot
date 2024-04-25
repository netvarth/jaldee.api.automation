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

${self}    0
${digits}       0123456789
${discount}        Disc11
${coupon}          wheat
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***

JD-TC-UpdateDeliveryCharge-1
    [Documentation]    Update Delivery Charge By provider for home delivery


    clear_queue    ${PUSERNAME130}
    clear_service  ${PUSERNAME130}
    # clear_customer   ${PUSERNAME130}
    clear_Item   ${PUSERNAME130}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME130}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME130}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  
    Set Suite Variable  ${itemName1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${eTime1}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable   ${maxQuantity}

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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
   
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+154686
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}${CUSERPH1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jaldee_id1}  ${resp.json()['id']}
    Set Test Variable  ${fname}  ${resp.json()['firstName']}
    Set Test Variable  ${lname}  ${resp.json()['lastName']}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${DAY1}
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    Set Suite Variable   ${item_quantity1}
    ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity11} 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH1}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERPH1}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id1}  ${resp.json()[0]['id']}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}

    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total}  deliveryCharges=${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total0}=  Evaluate  ${totalPrice1} + ${deliveryCharge0}
    Set Suite Variable   ${total0} 

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total0}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERPH1}
    Set Suite Variable   ${cid1}
    
    ${resp}=  Make payment Consumer Mock  ${accId1}  ${total0}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}      ${min_pre1}
    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    # Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}      ${cwid}
    # Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    # Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${total0}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${total0}  amountDue=0.0    totalTaxAmount=0.0

    sleep   1s
   
    ${resp}=   Get Order By Id   ${accId1}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total0}
    # Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                           ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                                    ${paymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                                      ${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            0.0


JD-TC-UpdateDeliveryCharge-2
    [Documentation]    Update Delivery Charge by reducing the charge

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge1}=  Random Int  min=1   max=49
    ${deliveryCharge1}=  Convert To Number  ${deliveryCharge1}  1
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${totalPrice1} + ${deliveryCharge1}

    ${refund}=  Evaluate  ${deliveryCharge1} - ${deliveryCharge0}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[3]}   totalAmountPaid=${total0}  amountDue=${refund}  deliveryCharges=${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total1}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                       ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                                    ${paymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                                      ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            ${refund}


JD-TC-UpdateDeliveryCharge-3
    [Documentation]    Update Delivery Charge after change status to order confirmed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${deliveryCharge1}=  Random Int  min=151   max=200
    ${deliveryCharge1}=  Convert To Number  ${deliveryCharge1}  1
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${totalPrice1} + ${deliveryCharge1}

    ${refund}=  Evaluate  ${deliveryCharge1} - ${deliveryCharge0}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[1]}   totalAmountPaid=${total0}  amountDue=${refund}  deliveryCharges=${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${StatusList[2]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total1}
    # Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                           ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                                    ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                                      ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            ${refund}


JD-TC-UpdateDeliveryCharge-4
    [Documentation]    Update Delivery Charge after change status to order shipped and update delivery chanrge to zero

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${deliveryCharge1}=  Random Int  min=0  max=0
    ${deliveryCharge1}=  Convert To Number  ${deliveryCharge1}  1
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${totalPrice1} + ${deliveryCharge1}

    ${refund}=  Evaluate  ${deliveryCharge1} - ${deliveryCharge0}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[3]}   totalAmountPaid=${total0}  amountDue=${refund}  deliveryCharges=${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${StatusList[6]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total1}
    # Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                       ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                                    ${paymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                                      ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            ${refund}


JD-TC-UpdateDeliveryCharge-5
    [Documentation]    Update Delivery Charge after change status to order completed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid1}   ${StatusList[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${deliveryCharge1}=  Random Int  min=155   max=200
    ${deliveryCharge1}=  Convert To Number  ${deliveryCharge1}  1
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${totalPrice1} + ${deliveryCharge1}

    ${Due_amt}=  Evaluate  ${deliveryCharge1} - ${deliveryCharge0}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid1}  netTotal=${totalPrice1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[1]}   totalAmountPaid=${total0}  amountDue=${Due_amt}  deliveryCharges=${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId1}  ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid1}  storePickup=${bool[0]}  orderStatus=${StatusList[4]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['quantity']}                             ${item_quantity1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice1}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${totalPrice1}
    Should Be Equal As Strings  ${resp.json()['cartAmount']}                                           ${total1}
    # Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                                      ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                           ${total0}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                                    ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                                      ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                                            ${Due_amt}


JD-TC-UpdateDeliveryCharge-6
    [Documentation]    Update Delivery Charge for home delivery when change order status to ready to delivery.

    clear_queue    ${PUSERNAME122}
    clear_service  ${PUSERNAME122}
    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid2}  ${decrypted_data['id']}
    # Set Test Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId2}=  get_acc_id  ${PUSERNAME122}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME122}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName2}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1


    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime}   eTime=${eTime}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}  ${orderStatuses[9]}  ${orderStatuses[8]}   ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1}
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14

    ${far_date}=   db.add_timezone_date  ${tz}   15
   
    ${soon}=  Random Int  min=1   max=1

    ${soon_date}=   db.add_timezone_date  ${tz}  11  
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
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

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity12}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId2}    ${self}    ${CatalogId2}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid2}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY1}  
    Should Be Equal As Strings  ${resp.json()['providerAccount']['id']}                                ${accId2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                       ${cons_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['firstName']}                                ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['lastName']}                                 ${lname}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}                           ${jaldee_id1}
    Should Be Equal As Strings  ${resp.json()['catalog']['id']}                                        ${CatalogId2}
    Should Be Equal As Strings  ${resp.json()['catalog']['catalogName']}                               ${catalogName}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice}=  Convert To Number  ${totalPrice}  1

    ${total}=  Evaluate  ${totalPrice} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${totalPrice}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total}  deliveryCharges=${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity12} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Change Order Status   ${orderid2}   ${StatusList1[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Status Changes by uid    ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${deliveryCharge1}=  Convert To Number  ${deliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid2}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${totalPrice} + ${deliveryCharge1}

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${totalPrice}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity12} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice} 
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}              0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}            ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['deliveryCharges']}              ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                    ${total1}


    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId2}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid2}  storePickup=${bool[0]}  orderStatus=${StatusList1[5]}  orderDate=${DAY1}  
    # Should Be Equal As Strings  ${resp.json()['bill']['items'][0]['itemName']}         ${displayName2} 
    # Should Be Equal As Strings  ${resp.json()['bill']['items'][0]['quantity']}         ${item_quantity1} 
    # Should Be Equal As Strings  ${resp.json()['bill']['items'][0]['price']}            ${promoPrice1} 
    # Should Be Equal As Strings  ${resp.json()['bill']['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['bill']['items'][0]['netRate']}          ${totalPrice} 
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                      0.0
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}            ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}              ${deliveryCharge1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                            ${total1}


JD-TC-UpdateDeliveryCharge-7
    [Documentation]    Update Delivery Charge By provider for home delivery.check bill after order taxable and non taxable items.
    

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+886532
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid3}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid3}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${accId3} 

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz3}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz3}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz3}
    ${sTime}=  add_timezone_time  ${tz3}  0  15  
    ${eTime}=  add_timezone_time  ${tz3}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200


    # clear_queue    ${PUSERNAME_C}
    # clear_service  ${PUSERNAME_C}
    # clear_customer   ${PUSERNAME_C}
    # clear_Item   ${PUSERNAME_C}
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pid3}  ${resp.json()['id']}
    
    # ${accId3}=  get_acc_id  ${PUSERNAME_C}
    # Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME_C}.${test_mail}

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

    ${startDate}=  db.get_date_by_timezone  ${tz3}
    ${endDate}=  db.add_timezone_date  ${tz3}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz3}
    ${endDate1}=  db.add_timezone_date  ${tz3}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime3}=  add_timezone_time  ${tz3}  0  15  
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz3}  3  30   
    Set Suite Variable    ${eTime3}
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Suite Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}

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

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
   
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+1546005
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERMAIL2}=   Set Variable  ${C_Email}${CUSERPH0}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH0}${\n}

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz3}  12  
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
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid3}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}


    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}

    sleep   1s
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
  
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid3}  ${accId3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
JD-TC-UpdateDeliveryCharge-8
    [Documentation]     Update Delivery Charge By provider for home delivery.check bill after order taxable and non taxable items and JDN.

    clear_queue    ${PUSERNAME124}
    clear_service  ${PUSERNAME124}
    clear_customer   ${PUSERNAME124}
    clear_Item   ${PUSERNAME124}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME124}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME120}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${disc_max}=   Random Int   min=100   max=500
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
    Should Be Equal As Strings   ${resp.json()['discMax']}          ${disc_max}
    Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${displayName0}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Test Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName0}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Test Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode0}=   FakerLibrary.word 

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName0}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName0}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode0}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id0}  ${resp.json()}

    ${displayName1}=   FakerLibrary.name 
    
    ${itemName1}=   FakerLibrary.name  
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id01}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  3  30   

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
   
    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime}   eTime=${eTime}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Test Variable  ${StatusList} 

    ${item1_Id}=  Create Dictionary  itemId=${item_id0}
    ${item2_Id}=  Create Dictionary  itemId=${item_id01}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}  max=${maxQuantity}
    ${item_quantity2}=  Convert To Number  ${item_quantity2}  1


    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME31}.${test_mail}


    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME31}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME31}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id0}    ${item_quantity1}  ${item_id01}    ${item_quantity2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid      ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}

    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity2} * ${promoPrice1}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    ${jdnamt}=  Evaluate  ${netTotal} * ${jdn_disc_percentage[0]} / 100
    ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
    ${amountDue}=  Evaluate  ${amountDue} - ${amount}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}
    ${total1}=  Evaluate  ${total1} - ${amount}
    ${total1}=  Convert To twodigitfloat  ${total1}

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 

    ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   


JD-TC-UpdateDeliveryCharge-9
    [Documentation]    Update Delivery Charge By provider for home delivery.check bill after order taxable and non taxable items and JDN,provider coupon,jaldee coupon.

    clear_queue    ${PUSERNAME124}
    clear_service  ${PUSERNAME124}
    clear_customer   ${PUSERNAME124}
    clear_Item   ${PUSERNAME124}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${pkgid}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    
    ${accId}=  get_acc_id  ${PUSERNAME124}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME120}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
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

     ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${alldomains}=  Jaldee Coupon Target Domains  ALL
    ${allsub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${pkgid}

    ${cupn_code}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    clear_jaldeecoupon  ${cupn_code}

    ${resp}=  Create Jaldee Coupon  ${cupn_code}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${alldomains}  ${allsub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code}  ${cupn_des}
    Should Be Equal As Strings   ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode   ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${jaldee_amt}    ${resp.json()['discountValue']}  
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code    ${cupn_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${desc}=  FakerLibrary.Sentence   nb_words=2
    Set Suite Variable    ${desc}
    # # ${disc_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${disc_amount}=  Set Variable    10.0
    # Set Suite Variable    ${disc_amount}
    # ${resp}=   Create Discount  ${discount}   ${desc}    ${disc_amount}   ${calctype[1]}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${disc_id}   ${resp.json()}
    # ${resp}=   Get Discount By Id  ${disc_id}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response   ${resp}   id=${disc_id}   name=${discount}   description=${desc}    discValue=${disc_amount}   calculationType=${calctype[1]}  status=${status[0]}

    # ${coupon_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    # ${coupon_amount}=  Set Variable    10.0
    # Set Suite Variable    ${coupon_amount}
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${coupon_amount}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${coupon_id}  ${resp.json()}
    # ${resp}=  Get Coupon By Id  ${coupon_id} 
    # Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${coupon_amount}  calculationType=${calctype[1]}  status=${status[0]}

    ${displayName0}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=150   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price1}

    ${price1float}=  twodigitfloat  ${price1}

    ${itemName0}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode0}=   FakerLibrary.word 

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName0}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName0}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode0}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id90}  ${resp.json()}

    ${displayName1}=   FakerLibrary.name 
    
    ${itemName1}=   FakerLibrary.name  
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id91}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  3  30   

    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
   
    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime}   eTime=${eTime}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id90}
    ${item2_Id}=  Create Dictionary  itemId=${item_id91}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId9}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${coupon_amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${coupon_amount}=  Set Variable    10.0
    Set Suite Variable    ${coupon_amount}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${cpn_sTime}=  db.get_time_by_timezone  ${tz}
    ${cpn_eTime}=  add_timezone_time  ${tz}  3  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[1]}
    ${tc}=  FakerLibrary.sentence
    ${items}=   Create list   ${item_id90}   ${item_id91}
    ${catalogues}=    Create List   ${CatalogId9}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${coupon_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${cpn_sTime}  ${cpn_eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  items=${items}  catalogues=${catalogues}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id2}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupon_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  9
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId}    ${self}    ${CatalogId9}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERPH0}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id90}    ${item_quantity1}  ${item_id91}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid9}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId}   ${orderid9}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Coupon By Id  ${coupon_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid   ${orderid9} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid9}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}

    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    ${jdnamt}=  Evaluate  ${netTotal} * ${jdn_disc_percentage[0]} / 100
    ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
    ${amountDue}=  Evaluate  ${amountDue} - ${amount}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    # ${amountDue}=  Evaluate  ${amountDue} - ${jdnamt}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}
    Verify Response  ${resp}  uuid=${orderid9}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    # ${reason}=   FakerLibrary.word
    # ${service}=  Service Bill  ${reason}  ${sid1}   1    ${disc_id}
    # ${resp}=  Update Bill  ${orderid}  ${action[6]}  ${service}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 


    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill  ${orderid9}  ${action[12]}  ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code}  ${orderid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${net_rate1}=           Evaluate   ${netTotal} - ${coupon_amount}
    # ${jdnamt}=  Evaluate  ${net_rate1} * ${jdn_disc_percentage[0]} / 100
    # ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
    # ${amount}=  Evaluate  ${net_rate1} - ${amount}
    # ${amount1}=  Evaluate  ${amount} + ${totalTaxAmount} + ${deliveryCharge}
    # ${net_rate2}=           Evaluate   ${amount1} - ${jaldee_amt}

    ${net_rate1}=           Evaluate   ${netTotal} - ${coupon_amount}
    ${jdnamt}=  Evaluate  ${netTotal} * ${jdn_disc_percentage[0]} / 100
    ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
    ${amount}=  Evaluate  ${net_rate1} - ${amount}
    ${amount1}=  Evaluate  ${amount} + ${totalTaxAmount} + ${deliveryCharge}
    ${net_rate2}=           Evaluate   ${amount1} - ${jaldee_amt}
    ${net_rate2}=  Convert To twodigitfloat  ${net_rate2}
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}

    Verify Response  ${resp}  uuid=${orderid9}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${net_rate2}  deliveryCharges=${deliveryCharge}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid9}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${amount1}=  Evaluate  ${amount} + ${totalTaxAmount} + ${deliveryCharge0}
    ${net_rate2}=           Evaluate   ${amount1} - ${jaldee_amt}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid9}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${net_rate2}  deliveryCharges=${deliveryCharge0}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid9}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid9}  netTotal=${netTotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}
    

JD-TC-UpdateDeliveryCharge-10
    [Documentation]    Update Delivery Charge By provider for home delivery first take order for 2 item and then remove taxable item

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1} 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid      ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}


    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge3}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${storecomment}=   FakerLibrary.word
    ${resp}=   Update Order Items By Provider   ${orderid}  ${item_id3}   ${item_quantity1}  ${storecomment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}

    ${amountDue}=  Evaluate  ${item_one} + ${deliveryCharge3}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    
    sleep  1s
    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${orderid}  netTotal=${item_one}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
    # Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
    # # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateDeliveryCharge-11
    [Documentation]  same consumer place an oder for both pick up and home delivery when Advanced_payment_type is Full_Amount

    clear_queue    ${PUSERNAME137}
    clear_service  ${PUSERNAME137}
    clear_customer   ${PUSERNAME137}
    clear_Item   ${PUSERNAME137}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME137}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid2}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid2}  ${resp.json()['id']}
    
    ${accId11}=  get_acc_id  ${PUSERNAME137}
    Set Suite Variable  ${accId11}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id2}  ${firstname}${PUSERNAME137}.${test_mail}

    ${resp}=  Update Email   ${pid2}   ${firstname}   ${lastname}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName11}=   FakerLibrary.name 
    Set Suite Variable  ${displayName11}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price11}=  Random Int  min=50   max=300
    ${price11}=  Convert To Number  ${price11}  1
    Set Suite Variable  ${price11}


    ${price1float}=  twodigitfloat  ${price11}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice11}=  Random Int  min=10   max=${price11} 
    ${promoPrice11}=  Convert To Number  ${promoPrice11}  1
    Set Suite Variable  ${promoPrice11}


    ${promoPrice2float}=  twodigitfloat  ${promoPrice11}

    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName11}    ${shortDesc1}    ${itemDesc1}    ${price11}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice11}   ${promotionalPrcnt2}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz11}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz11}
    ${endDate}=  db.add_timezone_date  ${tz11}  10        

    ${startDate1}=  db.add_timezone_date  ${tz11}  11  
    ${endDate1}=  db.add_timezone_date  ${tz11}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime2}=  add_timezone_time  ${tz11}  0  15  
    Set Suite Variable    ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz11}  3  30   
    Set Suite Variable    ${eTime2}  
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge2}=  Random Int  min=50   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity2}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable   ${maxQuantity2}

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

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}    ${catalogStatus[0]}
    Set Test Variable  ${paymentType3}     ${AdvancedPaymentType[2]}
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType3}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}    showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId11}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY11}=  db.add_timezone_date  ${tz11}  12  
    Set Suite Variable  ${DAY11}
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
      
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    ${item_quantity2}=  Convert To Number  ${item_quantity2}  1

    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}

    ${resp}=   Create Order For HomeDelivery  ${cookie}   ${accId11}    ${self}    ${CatalogId11}   ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY11}    ${CUSERNAME10}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id2}    ${item_quantity2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid11}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId11}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY12}=  db.add_timezone_date  ${tz11}   14
    ${address}=  get_address
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

    ${resp}=   Create Order For Pickup   ${cookie}   ${accId11}    ${self}    ${CatalogId11}   ${bool[1]}   ${sTime2}    ${eTime2}   ${DAY12}    ${CUSERNAME10}    ${email}  ${countryCodes[0]}  ${EMPTY_List}   ${item_id2}    ${item_quantity2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId11}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME137}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Order by uid    ${orderid11} 
    # # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()}   ${EMPTY}

    # ${resp}=   Get Order by uid    ${orderid12} 
    # # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()}   ${EMPTY}

    ${item_one}=  Evaluate  ${item_quantity2} * ${promoPrice11}
    ${item_one}=  Convert To Number  ${item_one}  1
    Set Suite Variable   ${item_one}  

    ${deliveryCharge2}=  Convert To Number  ${deliveryCharge2}  1
    Set Suite Variable   ${deliveryCharge2}   ${deliveryCharge2}
    
    ${totalTaxAmount}=  Evaluate  ${item_one} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${item_one} + ${totalTaxAmount} + ${deliveryCharge2}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    Set Suite Variable   ${amountDue}

    ${cid10}=  get_id  ${CUSERNAME10}
    Set Suite Variable   ${cid10}
    
    ${resp}=  Make payment Consumer Mock  ${accId11}  ${amountDue}  ${purpose[0]}  ${orderid11}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid10}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid11}  ${accId11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${amountDue}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${amountDue}  amountDue=0.0    totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge2}
    Should Be Equal As Numbers  ${resp.json()['netRate']}          ${amountDue} 

    ${resp}=   Get Order By Id   ${accId11}  ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}        ${orderid11}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME137}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cons_id4}  ${resp.json()[0]['id']}

    ${resp}=   Get Order by uid    ${orderid11} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}        ${orderid11}

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}   netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}   billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${amountDue}  amountDue=0.0    totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge2}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price11} 
    Should Be Equal As Numbers  ${resp.json()['items'][0]['netRate']}          ${item_one} 
    Should Be Equal As Numbers  ${resp.json()['netRate']}          ${amountDue} 

   
    ${deliveryCharge_1}=  Random Int  min=1   max=49
    ${deliveryCharge_1}=  Convert To Number  ${deliveryCharge_1}  1
    Set Suite Variable   ${deliveryCharge_1} 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid11}   ${deliveryCharge_1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total0}=  Evaluate  ${item_one} + ${totalTaxAmount} 
    Set Suite Variable   ${total0} 
    ${total1}=  Evaluate   ${total0} + ${deliveryCharge_1} 
    ${total1}=  twodigitfloat  ${total1} 
    
    ${refund}=  Evaluate  ${deliveryCharge_1} - ${deliveryCharge2}

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}   billPaymentStatus=${paymentStatus[3]}  totalAmountPaid=${amountDue}  amountDue=${refund}   totalTaxAmount=${totalTaxAmount}  deliveryCharges=${deliveryCharge_1}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price11} 
    Should Be Equal As Numbers  ${resp.json()['items'][0]['netRate']}          ${item_one} 
    Should Be Equal As Numbers  ${resp.json()['netRate']}          ${total1} 

   
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId11}  ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid11}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY11}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${item_one}
    Should Be Equal As Numbers  ${resp.json()['cartAmount']}                                           ${total1}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                            ${paymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                              ${deliveryCharge_1}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                                            ${refund}

  
JD-TC-UpdateDeliveryCharge-12
    [Documentation]    Update Delivery Charge by increasing the charge

    ${resp}=  Encrypted Provider Login  ${PUSERNAME137}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge11}=  Random Int  min=100   max=150
    ${deliveryCharge11}=  Convert To Number  ${deliveryCharge11}  1
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid11}   ${deliveryCharge11} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${total1}=  Evaluate  ${total0} + ${deliveryCharge11} 
    ${total1}=  twodigitfloat  ${total1} 

    ${refund}=  Evaluate  ${deliveryCharge11} - ${deliveryCharge2}

    ${resp}=  Get Bill By UUId  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid11}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[1]}   totalAmountPaid=${amountDue}  amountDue=${refund}  deliveryCharges=${deliveryCharge11}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName11} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice11} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price11} 
    Should Be Equal As Numbers  ${resp.json()['items'][0]['netRate']}          ${item_one} 
    # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${accId11}  ${orderid11}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response    ${resp}  homeDelivery=${bool[1]}    uid=${orderid11}  storePickup=${bool[0]}  orderStatus=${orderStatuses[0]}  orderDate=${DAY11}  
    Should Be Equal As Strings  ${resp.json()['orderFor']['id']}                                       ${cons_id4}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['id']}                                   ${item_id2}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['name']}                                 ${displayName11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['price']}                                ${promoPrice11}
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['status']}                               FULFILLED
    Should Be Equal As Strings  ${resp.json()['orderItem'][0]['totalPrice']}                           ${item_one}
    Should Be Equal As Numbers  ${resp.json()['cartAmount']}                                           ${total1}
    Should Be Equal As Strings  ${resp.json()['bill']['amountPaid']}                                   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['bill']['billPaymentStatus']}                            ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()['bill']['deliveryCharges']}                              ${deliveryCharge11}
    Should Be Equal As Numbers  ${resp.json()['amountDue']}                                            ${refund}

JD-TC-UpdateDeliveryCharge-UH1
    [Documentation]    Update Delivery Charge By provider for home delivery and then cancel the order and check bill

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz3}  12  
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

    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1} 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId3}    ${self}    ${CatalogId3}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id3}    ${item_quantity1}  ${item_id4}    ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
    # Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}


    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_two}=  Convert To Number  ${item_two}  1

    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge3}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge3}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName3} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice2} 
    Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price2} 
    # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
    # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
    ${resp}=  Change Order Status   ${orderid}   ${StatusList1[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Status Changes by uid    ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge0}=  Random Int  min=100   max=150
    ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
    Set Suite Variable   ${deliveryCharge0}
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${deliveryCharge0} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"  

JD-TC-UpdateDeliveryCharge-UH2
    [Documentation]    Update Delivery Charge after change status to order canceled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid2}   ${StatusList1[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid2}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CAN_NOT_UPDATE_BILL}"  


JD-TC-UpdateDeliveryCharge-UH3
    [Documentation]    Update Delivery Charge for another provider orderid .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CANNOT_VIEW_THE_BILL}"  


JD-TC-UpdateDeliveryCharge-UH4
    [Documentation]    Update Delivery Charge with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"  

JD-TC-UpdateDeliveryCharge-UH5
    [Documentation]    Update Delivery Charge for negative number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   -5
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${YOU_CANNOT_VIEW_THE_BILL}"  


JD-TC-UpdateDeliveryCharge-UH6
    [Documentation]    Update Delivery Charge without login

    ${deliveryCharge1}=  Random Int  min=100   max=150
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid1}   ${deliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419



JD-TC-UpdateDeliveryCharge-13
    [Documentation]   place an order by consumer using SHOPPINGLIST  and add items to bill. After that Provider update delivery charge

    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    # Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}

    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId13}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    Set Test Variable   ${displayName}   Total Bill Amount
    Set Test Variable   ${itemName}      All items bill
    Set Test Variable   ${itemCode}      NetBill  
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Bill_item_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId13}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word
    ${item}=  Item Bill  ${des}  ${Bill_item_id}   1

    ${resp}=  Update Bill   ${orderid}  addItem   ${item} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-UpdateDeliveryCharge-14
    [Documentation]   place an order by consumer using SHOPPINGLIST  and add items to bill.Consumer completes bill payment, after that Provider update delivery charge
    
    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid122}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}
    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId13}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    Set Test Variable   ${displayName}   Total Bill Amount
    Set Test Variable   ${itemName}      All items bill
    Set Test Variable   ${itemCode}      NetBill  
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Bill_item_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId13}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word
    ${item}=  Item Bill  ${des}  ${Bill_item_id}   3

    ${resp}=  Update Bill   ${orderid}  addItem   ${item} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmt}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid8}

    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmt}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmtDue}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmtDue}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-UpdateDeliveryCharge-15
    [Documentation]   place an order by consumer using SHOPPINGLIST  and add items to bill. After that Provider update delivery charge

    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}

    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId13}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz} 
    ${DAY2}=  db.add_timezone_date  ${tz}  30

    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name_C1}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name_C1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    
    ${cupn_code2}=    FakerLibrary.word
    ${cupn_name_C2}=   FakerLibrary.name
    clear_jaldeecoupon  ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name_C2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  300  ${bool[0]}  ${bool[0]}  100  100  1000  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
 
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
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


    Set Test Variable   ${displayName}   Total Bill Amount
    Set Test Variable   ${itemName}      All items bill
    Set Test Variable   ${itemCode}      NetBill  
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Bill_item_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId13}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}  ${cupn_code2}   ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word
    ${item}=  Item Bill  ${des}  ${Bill_item_id}   1

    ${resp}=  Update Bill   ${orderid}  addItem   ${item} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    




JD-TC-UpdateDeliveryCharge-16
    [Documentation]   place an order by consumer using SHOPPINGLIST  and add items to bill.Consumer completes bill payment, after that Provider update delivery charge
    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    # Set Suite Variable  ${pid122}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    # Set Test Variable   ${domain}    ${resp.json()['sector']}
    # Set Test Variable   ${subDomain}    ${resp.json()['subSector']}
    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId13}   ${resp.json()}

    # ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz} 
    ${DAY2}=  db.add_timezone_date  ${tz}  30

    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name_C1}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name_C1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${cupn_code2}=    FakerLibrary.word
    ${cupn_name_C2}=   FakerLibrary.name
    clear_jaldeecoupon  ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name_C2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  300  ${bool[0]}  ${bool[0]}  100  100  1000  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
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


    Set Test Variable   ${displayName}   Total Bill Amount
    Set Test Variable   ${itemName}      All items bill
    Set Test Variable   ${itemCode}      NetBill  
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Bill_item_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId13}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}  ${cupn_code2}   ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word
    ${item}=  Item Bill  ${des}  ${Bill_item_id}   3

    ${resp}=  Update Bill   ${orderid}  addItem   ${item} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmt}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid8}

    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmt}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmtDue}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmtDue}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-UpdateDeliveryCharge-17
    [Documentation]   place an order by consumer using SHOPPINGLIST and add Multiple items to bill.Consumer completes bill payment, after that Provider add more items and update delivery charge
    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    # Set Suite Variable  ${pid122}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    # Set Test Variable   ${domain}    ${resp.json()['sector']}
    # Set Test Variable   ${subDomain}    ${resp.json()['subSector']}
    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId13}   ${resp.json()}

    # ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz} 
    ${DAY2}=  db.add_timezone_date  ${tz}  30

    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name_C1}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name_C1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${cupn_code2}=    FakerLibrary.word
    ${cupn_name_C2}=   FakerLibrary.name
    clear_jaldeecoupon  ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name_C2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  300  ${bool[0]}  ${bool[0]}  100  100  1000  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
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

 
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 
    ${itemCode1}=   FakerLibrary.name  
    ${itemCode2}=   FakerLibrary.word  
    ${itemCode3}=   FakerLibrary.firstname  

    ${displayName1}=   FakerLibrary.name 
    ${displayName2}=   FakerLibrary.word 
    ${displayName3}=   FakerLibrary.firstname 

    ${itemName1}=   FakerLibrary.name  
    ${itemName2}=   FakerLibrary.word  
    ${itemName3}=   FakerLibrary.firstname  
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName1}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id1}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName2}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id2}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName3}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id3}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId13}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}  ${cupn_code2}   ${cupn_code1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word

    ${item1}=  Item Bill  ${des}  ${Bill_item_id1}   3
    ${resp}=  Update Bill   ${orderid}  addItem   ${item1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item2}=  Item Bill  ${des}  ${Bill_item_id2}   4
    ${resp}=  Update Bill   ${orderid}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item3}=  Item Bill  ${des}  ${Bill_item_id3}   2
    ${resp}=  Update Bill   ${orderid}  addItem   ${item3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmt}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid8}

    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmt}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${itemCode4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.name   
    ${itemName4}=   FakerLibrary.firstname  

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName4}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id4}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item2}=  Item Bill  ${des}  ${Bill_item_id2}   6
    ${resp}=  Update Bill   ${orderid}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item4}=  Item Bill  ${des}  ${Bill_item_id4}   5
    ${resp}=  Update Bill   ${orderid}  addItem   ${item4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmtDue}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmtDue}  ${purpose[1]}  ${orderid}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By UUId  ${orderid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-UpdateDeliveryCharge-18
    [Documentation]   place an order by consumer using SHOPPINGCART and add Multiple items to bill.Consumer completes bill payment, after that Provider add more items and update delivery charge
    clear_customer   ${PUSERNAME122}
    clear_Item   ${PUSERNAME122}
    clear_Coupon   ${PUSERNAME122}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    # Set Suite Variable  ${pid122}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    Set Test Variable   ${domain}    ${decrypted_data['sector']}
    Set Test Variable   ${subDomain}    ${decrypted_data['subSector']}

    # Set Suite Variable  ${pid122}  ${resp.json()['id']}
    # Set Test Variable   ${domain}    ${resp.json()['sector']}
    # Set Test Variable   ${subDomain}    ${resp.json()['subSector']}
    ${accId2}=  get_acc_id  ${PUSERNAME122}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz} 
    ${DAY2}=  db.add_timezone_date  ${tz}  30

    ${cupn_code1}=    FakerLibrary.word
    ${cupn_name_C1}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code1}
    ${resp}=  Create Jaldee Coupon  ${cupn_code1}  ${cupn_name_C1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${cupn_code2}=    FakerLibrary.word
    ${cupn_name_C2}=   FakerLibrary.name
    clear_jaldeecoupon  ${cupn_code2}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2}  ${cupn_name_C2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[1]}  10  300  ${bool[0]}  ${bool[0]}  100  100  1000  5  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
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

 
    ${itemNameInLocal}=  FakerLibrary.Sentence   nb_words=2 
    ${shortDesc}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc}=  FakerLibrary.Sentence   nb_words=3   
    ${price}=  Random Int  min=50   max=300 
    ${price}=  Convert To Number  ${price}  1
    ${pricefloat}=  twodigitfloat  ${price}
    ${promoPrice}=  Random Int  min=10   max=${price} 
    ${promoPrice}=  Convert To Number  ${promoPrice}  1
    ${promoPricefloat}=  twodigitfloat  ${promoPrice}
    ${promoPrcnt}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt}=  twodigitfloat  ${promoPrcnt}
    ${note}=  FakerLibrary.Sentence   
    ${promoLabel}=   FakerLibrary.word 

    ${itemCode1}=   FakerLibrary.name  
    ${itemCode2}=   FakerLibrary.word  
    ${itemCode3}=   FakerLibrary.firstname  

    ${displayName1}=   FakerLibrary.name 
    ${displayName2}=   FakerLibrary.word 
    ${displayName3}=   FakerLibrary.firstname 

    ${itemName1}=   FakerLibrary.name  
    ${itemName2}=   FakerLibrary.word  
    ${itemName3}=   FakerLibrary.firstname   

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName1}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id1}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName2}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id2}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName3}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id3}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${minQuantity}=  Random Int  min=1   max=30
    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity2}=  Convert To Number  ${item_quantity2}  1

    ${item1_Id}=  Create Dictionary  itemId=${Bill_item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${Bill_item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}

    ${item3_Id}=  Create Dictionary  itemId=${Bill_item_id3}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItemList2}=  Create List   ${catalogItem3}


    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime3}=  add_timezone_time  ${tz}  2  30  
    ${eTime3}=  add_timezone_time  ${tz}  2  40   

    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4


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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]} 
   
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.name  
    ${catalogName2}=   FakerLibrary.word  
    
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId18}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId19}   ${resp.json()}
    # ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${CatalogId}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId18}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId19}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY6}=  db.add_timezone_date  ${tz}   6
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    ${caption}=  FakerLibrary.Sentence   nb_words=4


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
                                               
    # ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId2}   ${caption}   ${self}    ${CatalogId18}   ${bool[1]}   ${address}   ${DAY6}    ${sTime1}    ${eTime1}    ${EMPTY}    ${C_email}  ${cupn_code2}   ${cupn_code1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${orderid}  ${orderid[0]}
    ${CouponList}=  Create List  ${cupn_code2}   ${cupn_code1}
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${accId2}    ${self}    ${CatalogId18}     ${bool[1]}    ${address}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH0}    ${C_email}  ${countryCodes[0]}  ${CouponList}  ${Bill_item_id1}    ${item_quantity1}  ${Bill_item_id2}    ${item_quantity2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid18}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId2}  ${orderid18}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=  FakerLibrary.Word

    ${item1}=  Item Bill  ${des}  ${Bill_item_id1}   3
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item2}=  Item Bill  ${des}  ${Bill_item_id2}   4
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item3}=  Item Bill  ${des}  ${Bill_item_id3}   2
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Bill By UUId  ${orderid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmt}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME19}
    Set Test Variable   ${cid8}

    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmt}  ${purpose[1]}  ${orderid18}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid18}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${itemCode4}=   FakerLibrary.name  
    ${displayName4}=   FakerLibrary.firstname 
    ${itemName4}=   FakerLibrary.word  

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc}    ${itemDesc}    ${price}    ${bool[0]}    ${itemName4}    ${itemNameInLocal}    ${promotionalPriceType[1]}    ${promoPrice}   ${promotionalPrcnt}    ${note}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Bill_item_id4}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Bill_item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item2}=  Item Bill  ${des}  ${Bill_item_id2}   6
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item3}=  Item Bill  ${des}  ${Bill_item_id3}   10
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item4}=  Item Bill  ${des}  ${Bill_item_id4}   5
    ${resp}=  Update Bill   ${orderid18}  addItem   ${item4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${NewDeliveryCharge1}=  Random Int  min=100   max=150
    ${NewDeliveryCharge1}=  Convert To Number  ${NewDeliveryCharge1}
 
    ${resp}=  Update Delivery charge    ${action[18]}   ${orderid18}   ${NewDeliveryCharge1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BillAmtDue}  ${resp.json()['amountDue']}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Make payment Consumer Mock  ${accId2}  ${BillAmtDue}  ${purpose[1]}  ${orderid18}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid18}  ${pid122}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By UUId  ${orderid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




*** Comments ***
JD-TC-Get_Cart_Details-13
    [Documentation]    Get order details and Order items when advance_payment_type is FULLAMOUNT.(JDN Enabled and Jaldee coupon applied by consumer)
    clear_queue    ${PUSERNAME59}
    clear_service  ${PUSERNAME59}
    clear_customer   ${PUSERNAME59}
    clear_Item   ${PUSERNAME59}
    clear_Coupon   ${PUSERNAME59}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid9}  ${resp.json()['id']}
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}


    ${accId9}=  get_acc_id  ${PUSERNAME59}
    Set Test Variable  ${accId9} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME59}.${test_mail}

    ${resp}=  Update Email   ${pid9}   ${firstname}   ${lastname}   ${email_id}
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
    ${price1}=  Random Int  min=50   max=300  
    ${price1}=  Convert To Number  ${price1}  1
    
    ${price1float}=  twodigitfloat  ${price1}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${promoLabel1}=   FakerLibrary.word 

    ${itemCode8}=   FakerLibrary.word 
    ${itemName8}=   FakerLibrary.name  
    ${displayName8}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}
    ${resp}=  Create Order Item    ${displayName8}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName8}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode8}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id8}  ${resp.json()}

    ${itemCode9}=   FakerLibrary.word 
    ${itemName9}=   FakerLibrary.name  
    ${displayName9}=   FakerLibrary.name 
    ${resp}=  Create Order Item    ${displayName9}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName9}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode9}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id9}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        
  
    ${noOfOccurance}=  Random Int  min=0   max=0
   
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  15   

    ${sTime2}=  add_timezone_time  ${tz}  0  17
    ${eTime2}=  add_timezone_time  ${tz}  0  30  
  
    ${list}=  Create List  1  2  3  4  5  6  7

    ${Del_Charge1}=  Random Int  min=50   max=100
    ${deliveryCharge1}=  Convert To Number  ${Del_Charge1}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
   
    ${minQuantity1}=  Random Int  min=1   max=30
    ${maxQuantity1}=  Random Int  min=${minQuantity1}   max=50

    ${catalogDesc}=   FakerLibrary.name 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge1}
    
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id8}
    ${item2_Id}=  Create Dictionary  itemId=${item_id9}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity1}   maxQuantity=${maxQuantity1}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Test Variable  ${ItemList1}
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName8}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingList   ${catalogName8}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId8}   ${resp.json()}

    ${catalogName9}=   FakerLibrary.name  
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName9}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${ItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId9}   ${resp.json()}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
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
    

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
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
    
    ${resp}=   Get Cart Details    ${accId9}   ${CatalogId8}   ${boolean[1]}   ${DAY1}    ${Coupon1_list}    ${item_id8}   ${item_quantity5}
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
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME27}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME27}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId9}    ${self}    ${CatalogId4}     ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY2}    ${CUSERNAME27}    ${email}  ${countryCodes[0]}  ${Coupon1_list}  ${item_id1}    ${item_quantity5}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}
    Set Suite Variable  ${prepayAmt}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${item_one}=  Evaluate  ${item_quantity5} * ${promoPrice2}
    ${item_one}=  Convert To Number  ${item_one}  1

    ${jdnamt}=  Evaluate  ${item_one} * ${jdn_disc_percentage[0]} / 100
    # ${jdnamt}=  Convert To Number  ${jdnamt}  1
    ${JDNTotal1}=  Evaluate  ${item_one} - ${jdnamt}
    ${coupon1}=  Evaluate  ${JDNTotal1} - 50
    ${coupon2}=  Evaluate  ${coupon1} * 10 / 100
    ${totalDiscount}=  Evaluate  ${jdnamt} + 50 + ${coupon2}

    ${netTotal}=  Evaluate  ${item_one} + ${Del_Charge2} - ${totalDiscount}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Order by uid    ${orderid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid8}=  get_id  ${CUSERNAME27}
    Set Suite Variable   ${cid8}


    ${resp}=  Make payment Consumer Mock  ${prepayAmt}  ${bool[1]}  ${orderid2}  ${pid1}  ${purpose[0]}  ${cid8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${orderid2}  netTotal=${item_one}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=${prepayAmt}  billPaymentStatus=${paymentStatus[2]}  totalAmountPaid=${prepayAmt}  amountDue=0.0    totalTaxAmount=0.0

    sleep   1s
   
    ${resp}=   Get Order By Id   ${accId3}  ${orderid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200









*** Comments ****
# JD-TC-UpdateDeliveryCharge-2
#     [Documentation]    Update Delivery Charge By provider for home delivery

#     clear_queue    ${PUSERNAME124}
#     clear_service  ${PUSERNAME124}
#     clear_customer   ${PUSERNAME124}
#     clear_Item   ${PUSERNAME124}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}
    
#     ${accId}=  get_acc_id  ${PUSERNAME124}
    
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     Set Test Variable  ${email_id}  ${firstname}${PUSERNAME120}.${test_mail}

#     ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
  
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

#     ${disc_max}=   Random Int   min=100   max=500
#     ${disc_max}=  Convert To Number   ${disc_max}
#     Set Suite Variable   ${disc_max}
#     ${d_note}=   FakerLibrary.word
#     ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Get JDN 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings   ${resp.json()['discPercentage']}   ${jdn_disc_percentage[0]}
#     Should Be Equal As Strings   ${resp.json()['discMax']}          ${disc_max}
#     Should Be Equal As Strings   ${resp.json()['status']}           ${Qstate[0]}

#     ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
#     ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Enable Tax
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${displayName0}=   FakerLibrary.name 
#     ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
#     ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
#     ${price1}=  Random Int  min=50   max=300 
#     ${price1}=  Convert To Number  ${price1}  1
#     Set Test Variable  ${price1}

#     ${price1float}=  twodigitfloat  ${price1}

#     ${itemName0}=   FakerLibrary.name  

#     ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
#     ${promoPrice1}=  Random Int  min=10   max=${price1} 
#     ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
#     Set Test Variable  ${promoPrice1}

#     ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

#     ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
#     ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

#     ${note1}=  FakerLibrary.Sentence   

#     ${itemCode0}=   FakerLibrary.word 

#     ${itemCode1}=   FakerLibrary.word 

#     ${promoLabel1}=   FakerLibrary.word 

#     ${resp}=  Create Order Item    ${displayName0}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName0}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode0}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id0}  ${resp.json()}

#     ${displayName1}=   FakerLibrary.name 
    
#     ${itemName1}=   FakerLibrary.name  
    
#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id01}  ${resp.json()}

#     ${startDate}=  db.get_date_by_timezone  ${tz}
#     ${endDate}=  db.add_timezone_date  ${tz}  10        

#     ${startDate1}=  db.get_date_by_timezone  ${tz}
#     ${endDate1}=  db.add_timezone_date  ${tz}  15        

#     ${noOfOccurance}=  Random Int  min=0   max=0

#     ${sTime}=  add_timezone_time  ${tz}  0  15  
#     ${eTime}=  add_timezone_time  ${tz}  3  30   

#     ${list}=  Create List  1  2  3  4  5  6  7
  
#     ${deliveryCharge}=  Random Int  min=50   max=100
#     ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

#     ${Title}=  FakerLibrary.Sentence   nb_words=2 
#     ${Text}=  FakerLibrary.Sentence   nb_words=4

#     ${minQuantity}=  Random Int  min=1   max=30
   
#     ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
#     ${catalogName}=   FakerLibrary.name  

#     ${catalogDesc}=   FakerLibrary.name 

#     ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

#     ${timeSlots1}=  Create Dictionary  sTime=${sTime}   eTime=${eTime}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
#     ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

#     ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

#     ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
#     ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

#     ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
#     Set Test Variable  ${StatusList} 
#     # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     # ${catalogItem}=  Create List   ${catalogItem1}
    
#     ${item1_Id}=  Create Dictionary  itemId=${item_id0}
#     ${item2_Id}=  Create Dictionary  itemId=${item_id01}
#     ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    
#     Set Test Variable  ${orderType}       ${OrderTypes[0]}
#     Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
#     Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

#     ${advanceAmount}=  Random Int  min=1   max=1000
   
#     ${far}=  Random Int  min=14  max=14
   
#     ${soon}=  Random Int  min=0   max=0
   
#     Set Test Variable  ${minNumberItem}   1

#     Set Test Variable  ${maxNumberItem}   5

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${CatalogId}   ${resp.json()}

#     ${resp}=  Get Order Catalog    ${CatalogId}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 

#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${DAY1}=  db.add_timezone_date  ${tz}  12  
#     ${address}=  get_address
#     ${delta}=  FakerLibrary.Random Int  min=10  max=90
#     ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
#     ${firstname}=  FakerLibrary.first_name
#     Set Test Variable  ${email}  ${firstname}${CUSERPH0}.${test_mail}

#     ${resp}=   Create Order For HomeDelivery    ${accId}    ${self}    ${CatalogId}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERPH0}    ${email}  ${item_id0}    ${item_quantity1}  ${item_id01}    ${item_quantity1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${orderid}  ${orderid[0]}

#     ${resp}=   Get Order By Id    ${accId}   ${orderid}   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Order by uid      ${orderid} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
#     Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid}
#     Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
#     Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
#     Should Be Equal As Strings  ${resp.json()['homeDeliveryAddress']}     ${address}

#     ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice1}
#     ${item_one}=  Convert To Number  ${item_one}  1
#     ${item_two}=  Evaluate  ${item_quantity1} * ${promoPrice1}
#     ${item_two}=  Convert To Number  ${item_two}  1

#     ${netTotal}=  Evaluate  ${item_one} + ${item_two}
#     ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
#     ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
#     ${jdnamt}=  Evaluate  ${netTotal} * ${jdn_disc_percentage[0]} / 100
#     ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
#     ${amountDue}=  Evaluate  ${amountDue} - ${amount}


#     ${resp}=  Get Bill By UUId  ${orderid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${amountDue}  deliveryCharges=${deliveryCharge}
#     Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
#     # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${netTotal} 
#     # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 
  
#     ${deliveryCharge0}=  Random Int  min=100   max=150
#     ${deliveryCharge0}=  Convert To Number  ${deliveryCharge0}  1
#     Set Suite Variable   ${deliveryCharge0}
#     ${resp}=  Update Delivery charge    ${action[18]}   ${orderid}   ${deliveryCharge0} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${total1}=  Evaluate   ${netTotal} + ${totalTaxAmount} + ${deliveryCharge0}
#     ${total1}=  Evaluate  ${total1} - ${jdnamt}

#     ${resp}=  Get Bill By UUId  ${orderid}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  uuid=${orderid}  netTotal=${netTotal}   billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  billPaymentStatus=${paymentStatus[0]}   totalAmountPaid=0.0  amountDue=${total1}  deliveryCharges=${deliveryCharge0}
#     Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}         ${displayName0} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}         ${item_quantity1} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['price']}            ${promoPrice1} 
#     Should Be Equal As Strings  ${resp.json()['items'][0]['orignalPrice']}     ${price1} 
#     # Should Be Equal As Strings  ${resp.json()['items'][0]['netRate']}          ${totalPrice1} 
#     # # Should Be Equal As Strings  ${resp.json()['createdDate']}                  ${bool[0]} 

#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
   