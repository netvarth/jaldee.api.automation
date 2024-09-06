*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        JaldeeCoupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/AppKeywords.robot



*** Variables ***
${self}    0
@{countryCode}     91   +91   48
${SERVICE1}    SERVICE1234511
${SERVICE2}    SERVICE1234522
${SERVICE3}    SERVICE1234533
${SERVICE4}    SERVICE1234544

${catalogName1}   catalog15Name1
${catalogName2}   catalog15Name2
${catalogName3}   catalog15Name3
${catalogName4}   catalog15Name4
${catalogName5}   catalog15Name5
${catalogName6}   catalog15Name6

${itemCode1}    item15Code811
${itemCode2}    item15Code822
${itemCode3}    item15Code833
${itemCode4}    item15Code844
${itemCode5}    item15Code855
${itemCode6}    item15Code866
${itemCode7}    item15Code877

${itemName1}    item15Name811
${itemName2}    item15Name822
${itemName3}    item15Name833
${itemName4}    item15Name844
${itemName5}    item15Name855
${itemName6}    item15Name866
${itemName7}    item15Name877

${displayName1}    display11Name88881
${displayName2}    display11Name88882
${displayName3}    display11Name88883
${displayName4}    display11Name88884
${displayName5}    display11Name88885
${displayName6}    display11Name88886
${displayName7}    display11Name88887

${jcash_name1}   JCash81118_offer1
${jcash_name2}   JCash81118_offer2
${jcash_name3}   JCash81118_offer3
${jcash_name4}   JCash81118_offer4
${jcash_name5}   JCash81118_offer5
${jcash_name6}   JCash81118_offer6
${jcash_name7}   JCash81118_offer7
${jcash_name8}   JCash81118_offer8
${jcash_name9}   JCash81118_offer9

${CUSERPH}      ${CUSERNAME}
${tz}   Asia/Kolkata




*** Test Cases ***

JD-TC-GetAvailableJcash-1

    [Documentation]    Set Jaldee Cash Global Max Spendlimit

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${global_max_limit}    ${resp.content}
    ${global_max_limit}=  Convert To Number  ${global_max_limit}  1
    Set Suite variable   ${global_max_limit}

    ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit} 
    ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    Set Suite Variable   ${maxSpendLimit}
     
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetRemainingAmountToPay-1
    [Documentation]    Get Remaining Amount To Pay when consumer try to use it for Shopping_Cart.
    clear_queue    ${PUSERNAME47}
    clear_service  ${PUSERNAME47}
    clear_customer   ${PUSERNAME47}
    clear_Item   ${PUSERNAME47}
    clear_Coupon   ${PUSERNAME47}

    ${Acc_pid1}=  get_acc_id  ${PUSERNAME47}
    ${Acc_pid2}=  get_acc_id  ${PUSERNAME28}
    ${Acc_pid3}=  get_acc_id  ${PUSERNAME133}
    ${Acc_pid4}=  get_acc_id  ${PUSERNAME101}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Cash Global Max Spendlimit
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${global_max_limit}    ${resp.json()}

    ${EMPTY_List}=  Create List
    Set Suite Variable   ${EMPTY_List}
    ${start_date}=  db.get_date_by_timezone  ${tz} 
    Set Suite Variable   ${start_date}
    ${end_date}=  db.add_timezone_date  ${tz}  12    
    Set Suite Variable   ${end_date}
    ${minOnlinePaymentAmt}=  Random Int  min=250   max=1000  
    ${minOnlinePaymentAmt}=  Convert To Number  ${minOnlinePaymentAmt}  1
    Set Suite Variable   ${minOnlinePaymentAmt}
    ${maxValidUntil}=  db.add_timezone_date  ${tz}   26  
    Set Suite Variable   ${maxValidUntil}
    ${validForDays}=  Random Int  min=5   max=10 
    Set Suite Variable   ${validForDays}
    ${ex_date}=    db.add_timezone_date  ${tz}   ${validForDays} 
    Set Suite Variable   ${ex_date}
    # ${maxSpendLimit}=  Random Int  min=10   max=${global_max_limit} 
    # ${maxSpendLimit}=  Convert To Number  ${maxSpendLimit}  1
    #  Set Suite Variable   ${maxSpendLimit}
    ${issueLimit}=  Random Int  min=1   max=5 
    Set Suite Variable   ${issueLimit}
    ${amt}=  Random Int  min=100   max=500  
    ${amt}=  Convert To Number  ${amt}   1
    Set Suite Variable   ${amt}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name1}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+439781
    # Set Suite Variable   ${CUSERPH0}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+4468
    # ${firstname_C0}=  FakerLibrary.first_name
    # ${lastname_C0}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERPH0_EMAIL}=   Set Variable  ${C_Email}${lastname_C0}${CUSERPH0}.${test_mail}
    # ${resp}=  Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERPH0}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${CPH0_id}   ${resp.json()['id']}
    

    ${CUSERPH0}=  Evaluate  ${CUSERPH}+3841231
    Set Suite Variable   ${CUSERPH0}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${firstname_C0}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname_C0} 
    ${lastname_C0}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname_C0} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname_C0}${CUSERPH0}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${CPH0_id}   ${resp.json()['id']}      



    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   2000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   20
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME47}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME47}.${test_mail}

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
    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

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
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.content}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${ItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    # ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${CatalogId1}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity1}   max=${maxQuantity1}
    ${EMPTY_List}=  Create List
    ${item3_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item4_price}=  Evaluate  ${price1} * ${promotionalPrcnt1} / 100
    ${item4_price}=  Evaluate  ${price1} - ${item4_price}
    ${item4_price}=  twodigitfloat  ${item4_price}
    ${item4_price}=  Evaluate  ${item4_price} * 1
    ${item4_total}=  Evaluate  ${item_quantity1} * ${item4_price}
    ${item4_total}=  Convert To twodigitfloat  ${item4_total}  
    ${netTotal}=  Evaluate  ${item3_total} + ${item4_total}
    ${netItemQuantity}=  Evaluate  ${item_quantity1} + ${item_quantity1}
    ${cartAmount}=  Evaluate  ${item3_total} + ${item4_total} + ${Del_Charge1}
    ${totalTaxAmount}=  Evaluate  ${item4_total} * ${gstpercentage[3]} / 100
    ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  Evaluate  ${totalTaxAmount} * 1
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${Del_Charge1}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}  
    Set Suite Variable  ${amountDue}

    ${resp}=   Get Cart Details    ${accId3}   ${CatalogId2}   ${boolean[1]}   ${DAY1}    ${EMPTY_List}    ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
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

    ${Amt_To_Pay}=  Evaluate  ${amountDue} - ${maxSpendLimit}
    ${Amt_To_Pay}=  Convert To twodigitfloat  ${Amt_To_Pay}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   ${amountDue}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${Amt_To_Pay}

# JD-TC-GetRemainingAmountToPay-2
#     [Documentation]    Get Remaining Amount To Pay when consumer has Remaining amount which is less than Maximum spend limit after some online shopping.

JD-TC-GetRemainingAmountToPay-3
    [Documentation]    Get Remaining Amount To Pay for shopping cart when consumer get more than one JCASH offer.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${num1}=  Random Int  min=5  max=10
    ${maxSpendLimit2}=  Evaluate  ${global_max_limit} - ${num1}  
    ${maxSpendLimit2}=  Convert To Number  ${maxSpendLimit2}  1
    Set Suite Variable   ${maxSpendLimit2}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name3}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${maxSpendLimit2}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id3}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}    ${maxSpendLimit2}

    # ${num2}=  Random Int  min=10  max=20
    # ${maxSpendLimit3}=  Evaluate  ${global_max_limit} - ${num2}  
    # ${maxSpendLimit3}=  Convert To Number  ${maxSpendLimit3}  1
    # Set Suite Variable   ${maxSpendLimit3}

    ${resp}=  Create Jaldee Cash Offer   ${jcash_name4}   ${ValueType[0]}  ${amt}  ${start_date}  ${end_date}  ${JCwhen[0]}  ${JCscope[5]}  ${EMPTY_List}  ${EMPTY_List}   ${EMPTY_List}  ${EMPTY_List}  ${EMPTY}  ${maxValidUntil}  ${validForDays}  ${EMPTY}  ${issueLimit}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${offer_id4}   ${resp.json()}
    ${resp}=  Get Jaldee Cash Offer By Id   ${offer_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['offerRedeemRules']['maxAmtSpendLimit']}    ${global_max_limit}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${CUSERPH2}=  Evaluate  ${CUSERNAME}+47801
    # Set Suite Variable   ${CUSERPH2}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+4468
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
    # ${firstname_C0}=  FakerLibrary.first_name
    # ${lastname_C0}=  FakerLibrary.last_name
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${CUSERPH2_EMAIL}=   Set Variable  ${C_Email}${lastname_C0}${CUSERPH2}.${test_mail}
    # ${resp}=  Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Activation  ${CUSERPH2}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${CPH2_id}   ${resp.json()['id']}


    ${CUSERPH2}=  Evaluate  ${CUSERPH}+76556
    Set Suite Variable   ${CUSERPH2}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
    ${firstname_C0}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname_C0} 
    ${lastname_C0}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname_C0} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname_C0}${CUSERPH2}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C0}  ${lastname_C0}  ${address}  ${CUSERPH2}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH2}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${CPH2_id}   ${resp.json()['id']}      



    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  3

    # Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['id']}                             ${offer_id}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashOffer']['name']}                           ${jcash_name1}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}                               ${CPH2_id}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['firstName']}         ${firstname_C0}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['lastName']}          ${lastname_C0}
    # Should Be Equal As Strings  ${resp.json()[0]['type']}                                         ${JCtype[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['originalAmt']}                                  ${amt}
    # Should Be Equal As Strings  ${resp.json()[0]['remainingAmt']}                                 ${amt}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issueSrc']}                   ${JCtype[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedDt']}                   ${start_date}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashIssueInfo']['issuedBy']}                   SA
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['expiryDt']}              ${ex_date}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendLimit']}            ${maxSpendLimit}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTgtScope']}         ${JCscope[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['jCashSpendRulesInfo']['spendTransactionType']}  ${JCscope[0]}    
    # Should Be Equal As Strings  ${resp.json()[0]['triggerWhen']}                                  ${JCwhen[0]}
    # Set Suite Variable   ${remainingAmt1}    ${resp.json()[0]['remainingAmt']}   

    ${Net_offer_Amt}=  Evaluate  ${maxSpendLimit} + ${maxSpendLimit2} + ${global_max_limit}
    ${Amt_To_Pay}=  Evaluate  ${amountDue} - ${Net_offer_Amt}
    ${Amt_To_Pay}=  Convert To twodigitfloat  ${Amt_To_Pay}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   ${amountDue}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${Amt_To_Pay}


JD-TC-GetRemainingAmountToPay-4
    [Documentation]    Get Remaining Amount To Pay for Appointment when consumer get more than one JCASH offer.

    # ${CUSERPH1}=  Evaluate  ${CUSERNAME}+10972081
    # Set Suite Variable   ${CUSERPH1}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+4468
    # ${firstname_C1}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname_C1}
    # ${lastname_C1}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname_C1}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname_C1}  ${lastname_C1}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH1}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${cons_id}   ${resp.json()['id']}    

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+988732
    Set Suite Variable   ${CUSERPH1}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    ${firstname_C1}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname_C1} 
    ${lastname_C1}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname_C1} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname_C1}${CUSERPH1}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C1}  ${lastname_C1}  ${address}  ${CUSERPH1}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id}   ${resp.json()['id']}      
                                                     

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH1}${\n}
    
    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    Set Test Variable   ${cash_id1}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME185}
    clear_location  ${PUSERNAME185}
    clear_customer   ${PUSERNAME185}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    # ${resp2}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[1]}   Set jaldeeIntegration Settings  ${boolean[0]}  ${EMPTY}   ${EMPTY}  
    # Run Keyword If   '${resp2}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp2}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    clear_appt_schedule   ${PUSERNAME185}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERPH1}  firstName=${firstname_C1}   lastName=${lastname_C1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid8}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid8}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid8}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname_C1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname_C1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${netTotal}   ${resp.json()['netTotal']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${firstname_C1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname_C1}

    ${resp}=  Get Bill By consumer  ${apptid1}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid1}  netTotal=${netTotal}

    ${Net_offer_Amt}=  Evaluate  ${maxSpendLimit} + ${maxSpendLimit2} + ${global_max_limit}
    ${Amt_To_Pay}=  Evaluate  ${netTotal} - ${Net_offer_Amt}
    ${Amt_To_Pay}=  Convert To twodigitfloat  ${Amt_To_Pay}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${netTotal}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${Amt_To_Pay}

    
JD-TC-GetRemainingAmountToPay-5
    [Documentation]    Get Remaining Amount To Pay for waitlist when consumer get more than one JCASH offer.

    # ${CUSERPH3}=  Evaluate  ${CUSERNAME}+295481
    # Set Suite Variable   ${CUSERPH3}
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    # ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+44868
    # ${firstname_C3}=  FakerLibrary.first_name
    # Set Suite Variable   ${firstname_C3}
    # ${lastname_C3}=  FakerLibrary.last_name
    # Set Suite Variable   ${lastname_C3}
    # ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    # ${gender}    Random Element    ${Genderlist}
    # ${resp}=  Consumer SignUp  ${firstname_C3}  ${lastname_C3}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH3}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable   ${cons_id}   ${resp.json()['id']}                                                         

    # Append To File  ${EXECDIR}/data/TDD_Logs/consumernumbers.txt  ${CUSERPH3}${\n}
    
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+9875412
    Set Suite Variable   ${CUSERPH3}

    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${firstname_C3}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname_C3} 
    ${lastname_C3}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname_C3} 
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERPH}+760654
    Set Test Variable  ${email}  ${firstname_C3}${CUSERPH3}${CUSERPH}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname_C3}  ${lastname_C3}  ${address}  ${CUSERPH3}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${CUSERPH3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cons_id}   ${resp.json()['id']}      
                                                     

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    Set Test Variable   ${cash_id1}    ${resp.json()[0]['id']}

    ${resp}=  Get Jaldee Cash Available By Id   ${cash_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_queue      ${PUSERNAME145}
    clear_location   ${PUSERNAME145}
    clear_service    ${PUSERNAME145}
    clear_customer   ${PUSERNAME145}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME145}
    Set Suite Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
    
    ${resp}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${ser_id1}    ${resp}  
     
    ${resp}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${netTotal}   ${resp.json()['netTotal']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${firstname_C3}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname_C3}

    ${resp}=  Get Bill By consumer  ${uuid}  ${acc_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${uuid}  netTotal=${netTotal}

    ${Net_offer_Amt}=  Evaluate  ${maxSpendLimit} + ${maxSpendLimit2} + ${global_max_limit}
    ${Amt_To_Pay}=  Evaluate  ${netTotal} - ${Net_offer_Amt}
    ${Amt_To_Pay}=  Convert To twodigitfloat  ${Amt_To_Pay}

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[0]}   ${netTotal}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${Amt_To_Pay}

 



JD-TC-GetRemainingAmountToPay-UH1
    [Documentation]    Get Remaining Amount To Pay without login.
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   20
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


JD-TC-GetRemainingAmountToPay-UH2
    [Documentation]    Get Remaining Amount To Pay by provider login.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   20
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  ${resp.content}  "${NO_PERMISSION}"


JD-TC-GetRemainingAmountToPay-UH3
    [Documentation]    Get Remaining Amount To Pay when advance amount is zero.
    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   0.0


JD-TC-GetRemainingAmountToPay-UH4
    [Documentation]    Get Remaining Amount To Pay when consumer doesn't have any Jaldee Cash offer.
    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get All Jaldee Cash Available
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0
    
    ${Advance}=  Random Int  min=50   max=100
    ${Advance}=  Convert To Number  ${Advance}  1

    ${resp}=  Get Remaining Amount To Pay   ${boolean[1]}  ${boolean[1]}   ${Advance}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${Advance}

JD-TC-GetRemainingAmountToPay-clear

    [Documentation]    Clear jash offers frm super admin.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_jcashoffer   ${jcash_name1}
    clear_jcashoffer   ${jcash_name2}
    clear_jcashoffer   ${jcash_name3}
    clear_jcashoffer   ${jcash_name4}
    clear_jcashoffer   ${jcash_name5}
    clear_jcashoffer   ${jcash_name6}
    clear_jcashoffer   ${jcash_name7}
    clear_jcashoffer   ${jcash_name8}
    clear_jcashoffer   ${jcash_name9}
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
