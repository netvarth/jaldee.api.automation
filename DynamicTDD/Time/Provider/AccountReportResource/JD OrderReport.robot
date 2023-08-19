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
@{countryCode}    91   +91   48
${self}    0
${digits}       0123456789
${discount}        Disc11
${coupon}          wheat

${catalogName1}    catalog1_Name1111
${catalogName2}    catalog1_Name2222
${catalogName3}    catalog1_Name3333
${catalogName4}    catalog1_Name4444
${catalogName5}    catalog1_Name5555

${displayName1}   Display11Name101
${displayName2}   Display11Name202
${displayName3}   Display11Name303
${displayName4}   Display11Name404
${displayName5}   Display11Name505
${itemName1}   ITEM1001
${itemName2}   ITEM2002
${itemName3}   ITEM3003
${itemName4}   ITEM4004
${itemName5}   ITEM5005
${itemCode1}   Item001Code1
${itemCode2}   Item001Code2
${itemCode3}   Item001Code3
${itemCode4}   Item001Code4
${itemCode5}   Item001Code5


${Status}           SUCCESS
${ReportType}       ORDER
@{DateCategory}     TODAY   LAST_WEEK   NEXT_WEEK   LAST_THIRTY_DAYS   NEXT_THIRTY_DAYS   DATE_RANGE
@{PaymentPurpose}     prePayment   billPayment   donation
@{PaymentMode}        Mock   Cash   DC   CC   NB   PPI   UPI
@{PaymentStatus}      SUCCESS   FAILED   INCOMPLETE   VOID 
@{TransactionType}    Order   Waitlist   Appointment   License   Donation
@{Filters}             orderStatus-eq   orderNumber-eq    providerOwnConsumerId-eq   orderMode-eq    catalog-eq   
@{OrderDateFilters}    orderDate-ge   orderDate-le
@{OrderTypeFilters}    homeDelivery-eq   storePickup-eq
@{BillStatus}       Not paid  Partially paid  Fully paid  Refund
@{orderMode}       Online   Walk in
@{ModeOfDelivery}           Home Delivery    Store PickUp


*** Test Cases ***

JD-TC-OrderReport-1
    [Documentation]     Consumers Create Order for home delivery and Generate order report

    clear_queue    ${PUSERNAME179}
    clear_service  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_Item   ${PUSERNAME179}
    clear_Catalog   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME179}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    # ${resp}=  Get Order Settings by account id
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings


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


    ${disc_max}=   Random Int   min=100   max=500
    ${disc_max}=  Convert To Number   ${disc_max}
    Set Suite Variable  ${disc_max}
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

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}
    Set Suite Variable  ${pid}     ${resp.json()['id']}
    Set Suite Variable  ${uniqueId}        ${resp.json()['uniqueId']}
    Set Suite Variable  ${licensePkgID}    ${resp.json()['licensePkgID']}
    Set Suite Variable  ${corpId}          ${resp.json()['corpId']}
    Set Suite Variable  ${branchId}        ${resp.json()['branchId']}
    Set Suite Variable  ${userSubdomain}   ${resp.json()['userSubdomain']}
    Set Suite Variable  ${profileId}       ${resp.json()['profileId']}
    Set Suite Variable  ${accEncUid}       ${resp.json()['accEncUid']}
    
    
  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float1}=  twodigitfloat  ${price1}
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    ${price1float2}=  twodigitfloat  ${price2}
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence   
    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[0]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc3}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc3}=  FakerLibrary.Sentence   nb_words=3   
    ${price3}=  Random Int  min=50   max=300 
    ${price3}=  Convert To Number  ${price3}  1
    ${price1float3}=  twodigitfloat  ${price3}
    ${itemNameInLocal3}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice3}=  Random Int  min=10   max=${price3} 
    ${promoPrice3}=  Convert To Number  ${promoPrice3}  1
    ${promoPrice3float}=  twodigitfloat  ${promoPrice3}
    ${promoPrcnt3}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt3}=  twodigitfloat  ${promoPrcnt3}
    ${note3}=  FakerLibrary.Sentence   
    ${promoLabel3}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc3}    ${itemDesc3}    ${price3}    ${bool[0]}    ${itemName3}    ${itemNameInLocal3}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt3}    ${note3}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel3}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc4}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc4}=  FakerLibrary.Sentence   nb_words=3   
    ${price4}=  Random Int  min=50   max=300 
    ${price4}=  Convert To Number  ${price4}  1
    ${price1float4}=  twodigitfloat  ${price4}
    ${itemNameInLocal4}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice4}=  Random Int  min=10   max=${price4} 
    ${promoPrice4}=  Convert To Number  ${promoPrice4}  1
    ${promoPrice4float}=  twodigitfloat  ${promoPrice4}
    ${promoPrcnt4}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt4}=  twodigitfloat  ${promoPrcnt4}
    ${note4}=  FakerLibrary.Sentence   
    ${promoLabel4}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc4}    ${itemDesc4}    ${price4}    ${bool[0]}    ${itemName4}    ${itemNameInLocal4}    ${promotionalPriceType[1]}    ${promoPrice4}   ${promotionalPrcnt4}    ${note4}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel4}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc5}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc5}=  FakerLibrary.Sentence   nb_words=3   
    ${price5}=  Random Int  min=50   max=300 
    ${price5}=  Convert To Number  ${price5}  1
    ${price1float5}=  twodigitfloat  ${price5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice5}=  Random Int  min=10   max=${price5} 
    ${promoPrice5}=  Convert To Number  ${promoPrice5}  1
    ${promoPrice5float}=  twodigitfloat  ${promoPrice5}
    ${promoPrcnt5}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt5}=  twodigitfloat  ${promoPrcnt5}
    ${note5}=  FakerLibrary.Sentence   
    ${promoLabel5}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc5}    ${itemDesc5}    ${price5}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice5}   ${promotionalPrcnt5}    ${note5}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel5}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${startDate}=  get_date
    ${endDate}=  add_date  10      
    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      
    ${noOfOccurance}=  Random Int  min=0   max=0
    ${sTime1}=   subtract_time  2  00
    ${eTime1}=   subtract_time  0  10
    ${sTime2}=  db.get_time
    ${eTime2}=  add_time   0  20 
    ${sTime3}=  add_time  0  25
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_time   0  40
    Set Suite Variable  ${eTime3} 
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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${catalog_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots3}
    ${pickUp_timeSlot}=  Create List  ${timeSlots2}   ${timeSlots3}
    ${homeDelivery_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${catalog_timeSlot}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${pickUp_timeSlot}
    ${deliverySchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${homeDelivery_timeSlot}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${deliverySchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${CatalogStatus1}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
    ${far}=  Random Int  min=14  max=20
    # ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}    0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType1}   ${orderStatuses}   ${ItemList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${item3_Id}=  Create Dictionary  itemId=${item_id3}
    ${item4_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList2}=  Create List   ${catalogItem3}  ${catalogItem4}
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${orderStatuses}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${ItemList3}=  Create List   ${catalogItem1}  ${catalogItem2}   ${catalogItem3}  ${catalogItem4}
    Set Suite Variable  ${paymentType3}     ${AdvancedPaymentType[2]}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType3}   ${orderStatuses}   ${ItemList3}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c19_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname19}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname19}   ${resp.json()['lastName']}
    Set Suite Variable  ${c19_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email1}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email1}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId1}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    Set Suite Variable  ${order_Uid1}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no1}  ${resp.json()['orderNumber']}

    ${item_one}=  Evaluate  ${item_quantity1} * ${promoPrice2}
    ${item_one}=  twodigitfloat  ${item_one}
    ${item4_price}=  Evaluate  ${price2} * ${promotionalPrcnt1} / 100
    ${item4_price}=  Evaluate  ${price2} - ${item4_price}
    ${item4_price}=  Convert To twodigitfloat  ${item4_price}
    # ${item4_price}=  Convert To Number  ${item4_price}  1
    ${item_two}=  Evaluate  ${item_quantity1} * ${item4_price} 
    ${item_two}=  twodigitfloat  ${item_two} 
    ${netTotal}=  Evaluate  ${item_one} + ${item_two}
    ${netItemQuantity}=  Evaluate  ${item_quantity1} + ${item_quantity1}
    ${cartAmount}=  Evaluate  ${item_one} + ${item_two} + ${deliveryCharge}
    # ${cartAmount}=  twodigitfloat  ${cartAmount}  
    ${totalTaxAmount}=  Evaluate  ${item_two} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${netTotal} + ${totalTaxAmount} + ${deliveryCharge}
    ${jdnamt}=  Evaluate  ${netTotal} * ${jdn_disc_percentage[0]} / 100
    ${amount}=        Set Variable If  ${jdnamt} > ${disc_max}   ${disc_max}   ${jdnamt}
    ${amountDue}=  Evaluate  ${amountDue} - ${amount}

    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c17_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname17}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname17}   ${resp.json()['lastName']}
    Set Suite Variable  ${c17_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName2}=   FakerLibrary.first_name 
    ${C_lastName2}=   FakerLibrary.name 
    ${C_num2}    Random Int  min=123456   max=999999
    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${C_num2}
    Set Test Variable  ${C_email2}  ${C_firstName2}${CUSERPH2}.${test_mail}
    ${homeDeliveryAddress2}=   FakerLibrary.name 
    ${city2}=  FakerLibrary.city
    ${landMark2}=  FakerLibrary.Sentence   nb_words=2 
    ${code2}=  Random Element    ${countryCodes}
    ${address2}=  Create Dictionary   phoneNumber=${CUSERPH2}    firstName=${C_firstName2}   lastName=${C_lastName2}   email=${C_email2}    address=${homeDeliveryAddress2}   city=${city2}   postalCode=${C_num2}    landMark=${landMark2}   countryCode=${countryCodes[0]}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME17}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME17}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId1}     ${bool[1]}    ${address2}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME17}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}   ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}
    Set Suite Variable  ${order_Uid2}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no2}  ${resp.json()['orderNumber']}


    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c15_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname15}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname15}   ${resp.json()['lastName']}
    Set Suite Variable  ${c15_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName3}=   FakerLibrary.first_name 
    ${C_lastName3}=   FakerLibrary.name 
    ${C_num3}    Random Int  min=123456   max=999999
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${C_num3}
    Set Test Variable  ${C_email3}  ${C_firstName3}${CUSERPH3}.${test_mail}
    ${homeDeliveryAddress3}=   FakerLibrary.name 
    ${city3}=  FakerLibrary.city
    ${landMark3}=  FakerLibrary.Sentence   nb_words=2 
    ${code3}=  Random Element    ${countryCodes}
    ${address3}=  Create Dictionary   phoneNumber=${CUSERPH3}    firstName=${C_firstName3}   lastName=${C_lastName3}   email=${C_email3}    address=${homeDeliveryAddress3}   city=${city3}   postalCode=${C_num3}    landMark=${landMark3}   countryCode=${countryCodes[0]}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME15}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME15}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId1}     ${bool[1]}    ${address3}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME15}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}
    Set Suite Variable  ${order_Uid3}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no3}  ${resp.json()['orderNumber']}

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid19}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC19}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c19_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c19_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c19_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC17}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c17_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c17_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c17_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC15}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c15_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c15_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c15_dob}   ${resp.json()[0]['dob']}
    

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${resp}=  Get Bill By UUId  ${order_Uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   New

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today      
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    
    ${filter2}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
    
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()['reportContent']['data']}


    ${filter3}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id2}   ${resp.json()}
    
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id3}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}   3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}   ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    change_system_date   1
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
           


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
        


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    END


    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[1]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    
    sleep  2s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}   3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode



        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    END

    resetsystem_time
    
*** comment *** 

JD-TC-OrderReport-2
    [Documentation]     Provider Create Order for consumers and their family members and Generate order report
    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c22_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname22}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname22}   ${resp.json()['lastName']}
    Set Suite Variable  ${c22_Uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c25_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname25}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname25}   ${resp.json()['lastName']}
    Set Suite Variable  ${c25_Uname}   ${resp.json()['userName']}

    clear_customer   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME22}  firstName=${fname22}   lastName=${lname22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid22}   ${resp.json()}

   
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid22}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_fid1}  ${resp.json()}


    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+200000
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid22}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_fid2}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid22}
    Log  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${C22_Jid1}   ${resp.json()[2]['jaldeeId']}
    Set Test Variable  ${cid22_id}  ${resp.json()[2]['id']}
    Set Test Variable  ${c22_JC1}  ${resp.json()[2]['jaldeeConsumer']}
    
    Set Test Variable  ${C22_Jid2}   ${resp.json()[1]['jaldeeId']}
    Set Test Variable  ${c22_fid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${c22_JC2}  ${resp.json()[1]['jaldeeConsumer']}
    Set Suite Variable  ${c22_F1_Uname}  ${resp.json()[1]['firstName']} ${resp.json()[1]['lastName']}

    Set Test Variable  ${C22_Jid3}   ${resp.json()[0]['jaldeeId']}
    Set Test Variable  ${c22_fid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${c22_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Test Variable  ${c22_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c22_F2_Uname}  ${resp.json()[0]['firstName']} ${resp.json()[0]['lastName']}


    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid22}   ${cid22}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid21}  ${orderid[0]}
    Set Test Variable  ${order_Uid21}  ${orderid[1]}

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid22}   ${mem_fid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid22}  ${orderid[0]}
    Set Test Variable  ${order_Uid22}  ${orderid[1]}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid22}   ${mem_fid2}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid23}  ${orderid[0]}
    Set Test Variable  ${order_Uid23}  ${orderid[1]}


    ${resp}=   Get Order by uid    ${order_Uid21} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${order_Uid22} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${order_Uid23} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME25}  firstName=${fname25}   lastName=${lname25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid25}   ${resp.json()}

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    ${gender3}    Random Element    ${Genderlist}
    ${note3}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid25}  ${firstname3}  ${lastname3}  ${dob3}  ${gender3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem25_fid1}  ${resp.json()}

    ${firstname4}=  FakerLibrary.first_name
    ${lastname4}=  FakerLibrary.last_name
    ${dob4}=  FakerLibrary.Date
    ${gender4}    Random Element    ${Genderlist}
    ${Familymember_ph4}=  Evaluate  ${PUSERNAME0}+200000
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid25}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4}  ${Familymember_ph4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem25_fid2}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid25}
    Log  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${C25_Jid1}   ${resp.json()[2]['jaldeeId']}
    Set Test Variable  ${cid25_id}  ${resp.json()[2]['id']}
    Set Test Variable  ${c25_JC1}  ${resp.json()[2]['jaldeeConsumer']}
    
    Set Test Variable  ${C25_Jid2}   ${resp.json()[1]['jaldeeId']}
    Set Test Variable  ${c25_fid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${c25_JC2}  ${resp.json()[1]['jaldeeConsumer']}
    Set Suite Variable  ${c25_F1_Uname}  ${resp.json()[1]['firstName']} ${resp.json()[1]['lastName']}

    Set Test Variable  ${C25_Jid3}   ${resp.json()[0]['jaldeeId']}
    Set Test Variable  ${c25_fid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${c25_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Test Variable  ${c25_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c25_F2_Uname}  ${resp.json()[0]['firstName']} ${resp.json()[0]['lastName']}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid25}   ${cid25}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid24}  ${orderid[0]}
    Set Test Variable  ${order_Uid24}  ${orderid[1]}

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid25}   ${mem25_fid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid25}  ${orderid[0]}
    Set Test Variable  ${order_Uid25}  ${orderid[1]}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid25}   ${mem25_fid2}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid26}  ${orderid[0]}
    Set Test Variable  ${order_Uid26}  ${orderid[1]}



    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid21}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no21}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid22}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no22}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid23}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no23}  ${resp.json()['orderNumber']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid24}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no24}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid25}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no25}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid26}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no26}  ${resp.json()['orderNumber']}

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    6                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${C22_Jid1}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c22_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no21}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[1]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${C22_Jid2}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c22_F1_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no22}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[1]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${C22_Jid3}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c22_F2_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no23}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[1]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${C25_Jid1}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c25_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no24}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[1]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${C25_Jid2}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c25_F1_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no25}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[1]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['2']}    ${C25_Jid3}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['3']}    ${c25_F2_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['6']}    ${order_no26}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['12']}   ${orderMode[1]}       # Mode


    change_system_date   2
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    6                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    

    FOR  ${i}  IN RANGE   6
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no21}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C22_Jid1}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c22_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no21}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no22}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C22_Jid2}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c22_F1_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no22}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no23}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C22_Jid3}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c22_F2_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no23}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no24}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C25_Jid1}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c25_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no24}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no25}'  # Order Number
        ...    Run Keywords 

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C25_Jid2}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c25_F1_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no25}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no26}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C25_Jid3}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c25_F2_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no26}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode

    END

    resetsystem_time
    


JD-TC-OrderReport-3
    [Documentation]     Provider Create Order for consumers family members using provider_consumer id of family members and Generate order report
    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c22_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname22}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname22}   ${resp.json()['lastName']}
    Set Suite Variable  ${c22_Uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c25_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname25}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname25}   ${resp.json()['lastName']}
    Set Suite Variable  ${c25_Uname}   ${resp.json()['userName']}

    clear_customer   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME22}  firstName=${fname22}   lastName=${lname22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid22}   ${resp.json()}

   
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${note}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid22}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_fid1}  ${resp.json()}


    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+200000
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid22}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_fid2}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid22}
    Log  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${C22_Jid1}   ${resp.json()[2]['jaldeeId']}
    Set Test Variable  ${cid22_id}  ${resp.json()[2]['id']}
    Set Test Variable  ${c22_JC1}  ${resp.json()[2]['jaldeeConsumer']}
    
    Set Test Variable  ${C22_Jid2}   ${resp.json()[1]['jaldeeId']}
    Set Test Variable  ${c22_fid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${c22_JC2}  ${resp.json()[1]['jaldeeConsumer']}
    Set Suite Variable  ${c22_F1_Uname}  ${resp.json()[1]['firstName']} ${resp.json()[1]['lastName']}

    Set Test Variable  ${C22_Jid3}   ${resp.json()[0]['jaldeeId']}
    Set Test Variable  ${c22_fid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${c22_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Test Variable  ${c22_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c22_F2_Uname}  ${resp.json()[0]['firstName']} ${resp.json()[0]['lastName']}


    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
 

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${mem_fid1}   ${mem_fid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid31}  ${orderid[0]}
    Set Test Variable  ${order_Uid31}  ${orderid[1]}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${mem_fid2}   ${mem_fid2}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid32}  ${orderid[0]}
    Set Test Variable  ${order_Uid32}  ${orderid[1]}


    ${resp}=   Get Order by uid    ${order_Uid31} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${order_Uid32} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  AddCustomer  ${CUSERNAME25}  firstName=${fname25}   lastName=${lname25}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid25}   ${resp.json()}

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    ${gender3}    Random Element    ${Genderlist}
    ${note3}=  FakerLibrary.word
    ${resp}=  AddFamilyMemberByProvider  ${cid25}  ${firstname3}  ${lastname3}  ${dob3}  ${gender3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem25_fid1}  ${resp.json()}

    ${firstname4}=  FakerLibrary.first_name
    ${lastname4}=  FakerLibrary.last_name
    ${dob4}=  FakerLibrary.Date
    ${gender4}    Random Element    ${Genderlist}
    ${Familymember_ph4}=  Evaluate  ${PUSERNAME0}+200000
    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid25}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4}  ${Familymember_ph4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem25_fid2}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${cid25}
    Log  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${C25_Jid1}   ${resp.json()[2]['jaldeeId']}
    Set Test Variable  ${cid25_id}  ${resp.json()[2]['id']}
    Set Test Variable  ${c25_JC1}  ${resp.json()[2]['jaldeeConsumer']}
    
    Set Test Variable  ${C25_Jid2}   ${resp.json()[1]['jaldeeId']}
    Set Test Variable  ${c25_fid1}  ${resp.json()[1]['id']}
    Set Test Variable  ${c25_JC2}  ${resp.json()[1]['jaldeeConsumer']}
    Set Suite Variable  ${c25_F1_Uname}  ${resp.json()[1]['firstName']} ${resp.json()[1]['lastName']}

    Set Test Variable  ${C25_Jid3}   ${resp.json()[0]['jaldeeId']}
    Set Test Variable  ${c25_fid2}  ${resp.json()[0]['id']}
    Set Test Variable  ${c25_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Test Variable  ${c25_JC3}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c25_F2_Uname}  ${resp.json()[0]['firstName']} ${resp.json()[0]['lastName']}



    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${mem25_fid1}   ${mem25_fid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid33}  ${orderid[0]}
    Set Test Variable  ${order_Uid33}  ${orderid[1]}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${mem25_fid2}   ${mem25_fid2}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERPH}    ${email}  ${EMPTY}  ${countryCode[1]}  ${item_id1}   ${item_quantity1}  ${item_id2}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Test Variable  ${orderid34}  ${orderid[0]}
    Set Test Variable  ${order_Uid34}  ${orderid[1]}



    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid31}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no31}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid32}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no32}  ${resp.json()['orderNumber']}

  
    ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid33}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no33}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid34}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no34}  ${resp.json()['orderNumber']}


    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${C22_Jid2}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c22_F1_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no31}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[1]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${C22_Jid3}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c22_F2_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no32}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[1]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${C25_Jid2}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c25_F1_Uname}       # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no33}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[1]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${C25_Jid3}           # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c25_F2_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERPH}        # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no34}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[1]}       # Mode
           

    change_system_date   3
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no31}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C22_Jid2}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c22_F1_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no31}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode
           

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no32}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C22_Jid3}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c22_F2_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no32}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no33}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C25_Jid2}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c25_F1_Uname}       # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no33}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no34}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${C25_Jid3}           # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c25_F2_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERPH}        # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no34}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[1]}       # Mode

    END

    resetsystem_time



JD-TC-OrderReport-4
    [Documentation]     Consumers Create Order using SHOPPINGLIST and add items to the bill. Generate order report after that

    clear_queue    ${PUSERNAME179}
    clear_service  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_Item   ${PUSERNAME179}
    clear_Catalog   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    
    
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float1}=  twodigitfloat  ${price1}
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    ${price1float2}=  twodigitfloat  ${price2}
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence   
    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[0]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc3}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc3}=  FakerLibrary.Sentence   nb_words=3   
    ${price3}=  Random Int  min=50   max=300 
    ${price3}=  Convert To Number  ${price3}  1
    ${price1float3}=  twodigitfloat  ${price3}
    ${itemNameInLocal3}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice3}=  Random Int  min=10   max=${price3} 
    ${promoPrice3}=  Convert To Number  ${promoPrice3}  1
    ${promoPrice3float}=  twodigitfloat  ${promoPrice3}
    ${promoPrcnt3}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt3}=  twodigitfloat  ${promoPrcnt3}
    ${note3}=  FakerLibrary.Sentence   
    ${promoLabel3}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc3}    ${itemDesc3}    ${price3}    ${bool[0]}    ${itemName3}    ${itemNameInLocal3}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt3}    ${note3}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel3}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc4}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc4}=  FakerLibrary.Sentence   nb_words=3   
    ${price4}=  Random Int  min=50   max=300 
    ${price4}=  Convert To Number  ${price4}  1
    ${price1float4}=  twodigitfloat  ${price4}
    ${itemNameInLocal4}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice4}=  Random Int  min=10   max=${price4} 
    ${promoPrice4}=  Convert To Number  ${promoPrice4}  1
    ${promoPrice4float}=  twodigitfloat  ${promoPrice4}
    ${promoPrcnt4}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt4}=  twodigitfloat  ${promoPrcnt4}
    ${note4}=  FakerLibrary.Sentence   
    ${promoLabel4}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc4}    ${itemDesc4}    ${price4}    ${bool[0]}    ${itemName4}    ${itemNameInLocal4}    ${promotionalPriceType[1]}    ${promoPrice4}   ${promotionalPrcnt4}    ${note4}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel4}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc5}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc5}=  FakerLibrary.Sentence   nb_words=3   
    ${price5}=  Random Int  min=50   max=300 
    ${price5}=  Convert To Number  ${price5}  1
    ${price1float5}=  twodigitfloat  ${price5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice5}=  Random Int  min=10   max=${price5} 
    ${promoPrice5}=  Convert To Number  ${promoPrice5}  1
    ${promoPrice5float}=  twodigitfloat  ${promoPrice5}
    ${promoPrcnt5}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt5}=  twodigitfloat  ${promoPrcnt5}
    ${note5}=  FakerLibrary.Sentence   
    ${promoLabel5}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc5}    ${itemDesc5}    ${price5}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice5}   ${promotionalPrcnt5}    ${note5}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel5}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${startDate}=  get_date
    ${endDate}=  add_date  10      
    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      
    ${noOfOccurance}=  Random Int  min=0   max=0
    ${sTime1}=   subtract_time  2  00
    ${eTime1}=   subtract_time  0  10
    ${sTime2}=  db.get_time
    ${eTime2}=  add_time   0  20 
    ${sTime3}=  add_time  0  25
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_time   0  40
    Set Suite Variable  ${eTime3} 
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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${catalog_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots3}
    ${pickUp_timeSlot}=  Create List  ${timeSlots2}   ${timeSlots3}
    ${homeDelivery_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${catalog_timeSlot}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${pickUp_timeSlot}
    ${deliverySchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${homeDelivery_timeSlot}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${deliverySchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}

    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${CatalogStatus1}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
    ${far}=  Random Int  min=14  max=20
    # ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}    0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    
    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType1}   ${orderStatuses}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${item3_Id}=  Create Dictionary  itemId=${item_id3}
    ${item4_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList2}=  Create List   ${catalogItem3}  ${catalogItem4}
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}
    ${resp}=  Create Catalog For ShoppingList   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType2}   ${orderStatuses}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c19_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname19}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname19}   ${resp.json()['lastName']}
    Set Suite Variable  ${c19_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email1}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email1}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    # ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    # ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address1}   ${DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    Set Suite Variable  ${order_Uid1}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no1}  ${resp.json()['orderNumber']}

    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c17_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname17}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname17}   ${resp.json()['lastName']}
    Set Suite Variable  ${c17_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName2}=   FakerLibrary.first_name 
    ${C_lastName2}=   FakerLibrary.name 
    ${C_num2}    Random Int  min=123456   max=999999
    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${C_num2}
    Set Test Variable  ${C_email2}  ${C_firstName2}${CUSERPH2}.${test_mail}
    ${homeDeliveryAddress2}=   FakerLibrary.name 
    ${city2}=  FakerLibrary.city
    ${landMark2}=  FakerLibrary.Sentence   nb_words=2 
    ${code2}=  Random Element    ${countryCodes}
    ${address2}=  Create Dictionary   phoneNumber=${CUSERPH2}    firstName=${C_firstName2}   lastName=${C_lastName2}   email=${C_email2}    address=${homeDeliveryAddress2}   city=${city2}   postalCode=${C_num2}    landMark=${landMark2}   countryCode=${code2}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME17}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME17}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address2}   ${DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}
    Set Suite Variable  ${order_Uid2}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no2}  ${resp.json()['orderNumber']}


    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c15_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname15}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname15}   ${resp.json()['lastName']}
    Set Suite Variable  ${c15_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName3}=   FakerLibrary.first_name 
    ${C_lastName3}=   FakerLibrary.name 
    ${C_num3}    Random Int  min=123456   max=999999
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${C_num3}
    Set Test Variable  ${C_email3}  ${C_firstName3}${CUSERPH3}.${test_mail}
    ${homeDeliveryAddress3}=   FakerLibrary.name 
    ${city3}=  FakerLibrary.city
    ${landMark3}=  FakerLibrary.Sentence   nb_words=2 
    ${code3}=  Random Element    ${countryCodes}
    ${address3}=  Create Dictionary   phoneNumber=${CUSERPH3}    firstName=${C_firstName3}   lastName=${C_lastName3}   email=${C_email3}    address=${homeDeliveryAddress3}   city=${city3}   postalCode=${C_num3}    landMark=${landMark3}   countryCode=${code3}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME15}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME15}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address3}   ${DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME15}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid3}  ${orderid[0]}
    Set Suite Variable  ${order_Uid3}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid3}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no3}  ${resp.json()['orderNumber']}

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid19}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC19}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c19_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c19_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c19_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC17}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c17_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c17_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c17_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC15}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c15_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c15_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c15_dob}   ${resp.json()[0]['dob']}
    

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${resp}=  Get Bill By UUId  ${order_Uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billStatus']}   New



    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    
    ${filter2}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()['reportContent']['data']}


    ${filter3}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}   3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}   ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode


    ${resp}=  Get Bill By UUId  ${order_Uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${des}=  FakerLibrary.Word
    Set Suite Variable   ${des}

    ${item1}=  Item Bill  ${des}  ${item_id1}  1
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${item2}=  Item Bill  ${des}  ${item_id2}  1
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item3}=  Item Bill  ${des}  ${item_id3}  1
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}   3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}   ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    change_system_date   3
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    
    END
    

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[1]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    
    END

    resetsystem_time


JD-TC-OrderReport-5
    [Documentation]     Consumers Create Order using SHOPPINGLIST. Add items to the bill and completes bill payment. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${resp}=  Get Bill By UUId  ${order_Uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${des}=  FakerLibrary.Word

    ${item1}=  Item Bill  ${des}  ${item_id1}  1
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${item2}=  Item Bill  ${des}  ${item_id2}  2
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item3}=  Item Bill  ${des}  ${item_id3}  3
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item4}=  Item Bill  ${des}  ${item_id4}  4
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${BillAmount}   ${resp.json()['netRate']}


    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid19}=  get_id  ${CUSERNAME19}
    Set Suite Variable   ${cid19}

    ${resp}=  Make payment Consumer Mock  ${BillAmount}  ${bool[1]}  ${order_Uid1}  ${pid1}  ${purpose[1]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${order_Uid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   1s
   
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${BillAmount}         # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode

    

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[0]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}   3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}   ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${BillAmount}         # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no2}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}       # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c15_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c15_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME15}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no3}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                   # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}       # Mode


    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${BillAmount}         # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[2]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
           

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    END

    ${filter4}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[0]}   
    ${resp}=  Generate Report REST details  ${reportType}  ${DateCategory[1]}  ${filter4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${BillAmount}         # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[2]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no2}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no2}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no3}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c15_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c15_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME15}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no3}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                   # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode

    END

    resetsystem_time



JD-TC-OrderReport-6
    [Documentation]     Consumers Create Order using SHOPPINGLIST. Add items to the bill and completes bill payment.After bill payment provider again add more items to the bill and Generate order report

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${item3_update}=  Item Bill  ${des}  ${item_id3}  5
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item3_update} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item4_update}=  Item Bill  ${des}  ${item_id4}  7
    ${resp}=  Update Bill   ${order_Uid1}  addItem   ${item4_update} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${NetRate}   ${resp.json()['netRate']}
    Set Suite Variable   ${BalanceAmount}   ${resp.json()['amountDue']}


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${BillAmount}            # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[1]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid19}=  get_id  ${CUSERNAME19}
    Set Suite Variable   ${cid19}

    ${resp}=  Make payment Consumer Mock  ${BalanceAmount}  ${bool[1]}  ${order_Uid1}  ${pid1}  ${purpose[1]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   02s

    ${resp}=  Get Payment Details  account-eq=${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${order_Uid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
   
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${NetRate}            # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           

    change_system_date   5
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${NetRate}            # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[2]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    END
    resetsystem_time      


JD-TC-OrderReport-7
    [Documentation]     Consumers Create Order using SHOPPINGLIST. Add items to the bill and completes bill payment.After bill payment provider remove few items from bill and Generate order report
    
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]

    ${item3_update}=  Item Bill  ${des}  ${item_id3}  2
    ${resp}=  Update Bill   ${order_Uid1}  ${action[5]}   ${item3_update} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${item4_update}=  Item Bill  ${des}  ${item_id4}  3
    ${resp}=  Update Bill   ${order_Uid1}  ${action[5]}   ${item4_update} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${resp}=  Get Bill By UUId  ${order_Uid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${NetRate2}   ${resp.json()['netRate']}
    Set Suite Variable   ${RefundAmount}   ${resp.json()['amountDue']}


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}        # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}            # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}          # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}       # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no1}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${NetRate}            # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                   # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[3]}      # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}       # Mode
           
    change_system_date   6
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    3                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   3
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no1}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}        # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}            # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}          # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}    # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}       # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no1}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${NetRate}            # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                   # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[3]}      # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}       # Mode
    END
    resetsystem_time      



JD-TC-OrderReport-8
    [Documentation]     Consumers Create Order using SHOPPINGCART and SHOPPINGLIST when autoConfirm is TRUE. Generate order report after that

    clear_queue    ${PUSERNAME179}
    clear_service  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_Item   ${PUSERNAME179}
    clear_Catalog   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    
    
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float1}=  twodigitfloat  ${price1}
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    ${price1float2}=  twodigitfloat  ${price2}
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence   
    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[0]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc3}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc3}=  FakerLibrary.Sentence   nb_words=3   
    ${price3}=  Random Int  min=50   max=300 
    ${price3}=  Convert To Number  ${price3}  1
    ${price1float3}=  twodigitfloat  ${price3}
    ${itemNameInLocal3}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice3}=  Random Int  min=10   max=${price3} 
    ${promoPrice3}=  Convert To Number  ${promoPrice3}  1
    ${promoPrice3float}=  twodigitfloat  ${promoPrice3}
    ${promoPrcnt3}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt3}=  twodigitfloat  ${promoPrcnt3}
    ${note3}=  FakerLibrary.Sentence   
    ${promoLabel3}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc3}    ${itemDesc3}    ${price3}    ${bool[0]}    ${itemName3}    ${itemNameInLocal3}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt3}    ${note3}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel3}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${startDate}=  get_date
    ${endDate}=  add_date  10      
    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      
    ${noOfOccurance}=  Random Int  min=0   max=0
    ${sTime1}=   subtract_time  2  00
    ${eTime1}=   subtract_time  0  10
    ${sTime2}=  db.get_time
    ${eTime2}=  add_time   0  20 
    ${sTime3}=  add_time  0  25
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_time   0  40
    Set Suite Variable  ${eTime3} 
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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${catalog_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots3}
    ${pickUp_timeSlot}=  Create List  ${timeSlots2}   ${timeSlots3}
    ${homeDelivery_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${catalog_timeSlot}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${pickUp_timeSlot}
    ${deliverySchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${homeDelivery_timeSlot}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${deliverySchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}

    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${CatalogStatus1}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
    ${far}=  Random Int  min=14  max=20
    # ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}    0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    
    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType1}   ${orderStatuses}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList2}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType1}   ${orderStatuses}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c19_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname19}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname19}   ${resp.json()['lastName']}
    Set Suite Variable  ${c19_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email1}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email1}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

   
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address1}   ${DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid81}  ${orderid[0]}
    Set Suite Variable  ${order_Uid81}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid81}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no81}  ${resp.json()['orderNumber']}

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid82}  ${orderid[0]}
    Set Suite Variable  ${order_Uid82}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid82}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no82}  ${resp.json()['orderNumber']}

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c17_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname17}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname17}   ${resp.json()['lastName']}
    Set Suite Variable  ${c17_Uname}   ${resp.json()['userName']}
    

    # ${DAY1}=  add_date   12
    ${DAY1}=  get_date
    ${C_firstName2}=   FakerLibrary.first_name 
    ${C_lastName2}=   FakerLibrary.name 
    ${C_num2}    Random Int  min=123456   max=999999
    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${C_num2}
    Set Test Variable  ${C_email2}  ${C_firstName2}${CUSERPH2}.${test_mail}
    ${homeDeliveryAddress2}=   FakerLibrary.name 
    ${city2}=  FakerLibrary.city
    ${landMark2}=  FakerLibrary.Sentence   nb_words=2 
    ${code2}=  Random Element    ${countryCodes}
    ${address2}=  Create Dictionary   phoneNumber=${CUSERPH2}    firstName=${C_firstName2}   lastName=${C_lastName2}   email=${C_email2}    address=${homeDeliveryAddress2}   city=${city2}   postalCode=${C_num2}    landMark=${landMark2}   countryCode=${code2}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME17}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME17}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200


    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address2}   ${DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid83}  ${orderid[0]}
    Set Suite Variable  ${order_Uid83}  ${orderid[1]}

    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid83}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no83}  ${resp.json()['orderNumber']}

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address2}    ${sTime3}    ${eTime3}   ${DAY1}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid84}  ${orderid[0]}
    Set Suite Variable  ${order_Uid84}  ${orderid[1]}
    
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid84}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no84}  ${resp.json()['orderNumber']}

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid19}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC19}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c19_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c19_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c19_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC17}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c17_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c17_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c17_dob}   ${resp.json()[0]['dob']}


    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   5
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-9
    [Documentation]     Change order status from Order_Confirmed to Order_Received when autoConfirm is TRUE. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Received        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Received        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time


JD-TC-OrderReport-10
    [Documentation]     Change order status into Order_Acknowledged. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Acknowledged        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Acknowledged        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   3
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Acknowledged        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords
        
        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Acknowledged        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-11
    [Documentation]     Change order status into Order_Confirmed. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   2
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-12
    [Documentation]     Change order status into Preparing. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Preparing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Preparing       # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Preparing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Preparing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   3
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Preparing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Preparing       # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Preparing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Preparing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time


JD-TC-OrderReport-13
    [Documentation]     Change order status into Packing. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Packing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Packing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Packing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Packing        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Packing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Packing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Packing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Packing        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time

  

JD-TC-OrderReport-14
    [Documentation]     Change order status into Payment_Required. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Payment Required        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Payment Required        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Payment Required        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Payment Required        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   5
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Payment Required        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Payment Required        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Payment Required        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Payment Required        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time


JD-TC-OrderReport-15
    [Documentation]     Change order status into Ready_For_Pickup. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Ready For Pickup        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Ready For Pickup        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Ready For Pickup        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Ready For Pickup        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Pickup        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Pickup        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Pickup        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Pickup        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time


JD-TC-OrderReport-16
    [Documentation]     Change order status into Ready_For_Shipment. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[7]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Ready For Shipment        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Ready For Shipment        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Ready For Shipment        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Ready For Shipment        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Shipment        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Shipment        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Shipment        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Shipment        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-17
    [Documentation]     Change order status into Ready_For_Delivery. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Ready For Delivery        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Ready For Delivery        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Ready For Delivery        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Ready For Delivery        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Delivery        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Delivery        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Delivery        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Ready For Delivery        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-18
    [Documentation]     Change order status into Completed. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Completed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Completed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Completed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Completed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Completed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Completed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Completed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Completed        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-19
    [Documentation]     Change order status into In_Transit. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[10]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[10]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[10]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[10]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    In Transit        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    In Transit        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    In Transit        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    In Transit        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    In Transit        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    In Transit        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    In Transit        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    In Transit        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-20
    [Documentation]     Change order status into Shipped. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[11]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[12]['orderStatus']}         ${orderStatuses[11]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[11]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[11]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[11]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[11]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[11]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[12]['orderStatus']}         ${orderStatuses[11]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Shipped        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Shipped        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Shipped        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Shipped        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Shipped        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Shipped        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Shipped        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Shipped        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-21
    [Documentation]     Change order status into Cancelled. Generate order report after that

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${resp}=  Change Order Status   ${order_Uid81}   ${orderStatuses[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid81}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[12]['orderStatus']}         ${orderStatuses[11]}
    Should Be Equal As Strings  ${resp.json()[13]['orderStatus']}         ${orderStatuses[12]}

    ${resp}=  Change Order Status   ${order_Uid82}   ${orderStatuses[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid82}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[11]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[12]}

    ${resp}=  Change Order Status   ${order_Uid83}   ${orderStatuses[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid83}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[11]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[12]}

    ${resp}=  Change Order Status   ${order_Uid84}   ${orderStatuses[12]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid84}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[1]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[4]['orderStatus']}         ${orderStatuses[3]}
    Should Be Equal As Strings  ${resp.json()[5]['orderStatus']}         ${orderStatuses[4]}
    Should Be Equal As Strings  ${resp.json()[6]['orderStatus']}         ${orderStatuses[5]}
    Should Be Equal As Strings  ${resp.json()[7]['orderStatus']}         ${orderStatuses[6]}
    Should Be Equal As Strings  ${resp.json()[8]['orderStatus']}         ${orderStatuses[7]}
    Should Be Equal As Strings  ${resp.json()[9]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[10]['orderStatus']}         ${orderStatuses[9]}
    Should Be Equal As Strings  ${resp.json()[11]['orderStatus']}         ${orderStatuses[10]}
    Should Be Equal As Strings  ${resp.json()[12]['orderStatus']}         ${orderStatuses[11]}
    Should Be Equal As Strings  ${resp.json()[13]['orderStatus']}         ${orderStatuses[12]}

    ${DAY1}=  get_date
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Test Variable   ${Order_Date1}    ${TODAY} [${sTime3} To ${eTime3}]


    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${DAY1}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no81}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Cancelled        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no82}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Cancelled        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no83}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Cancelled        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_Date1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no84}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Cancelled        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    change_system_date   4
    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}   
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    4                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    FOR  ${i}  IN RANGE   4
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no81}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no81}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Cancelled        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
           
    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no82}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c19_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c19_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no82}          # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Cancelled        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no83}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no83}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Cancelled        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['6']}' == '${order_no84}'  # Order Number
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_Date1}         # Order Date
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no84}           # Order Number
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Cancelled        # Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
        ...    AND  Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    END
    resetsystem_time



JD-TC-OrderReport-22
    [Documentation]     Generate report of Home Delivery orders

    clear_queue    ${PUSERNAME179}
    clear_service  ${PUSERNAME179}
    clear_customer   ${PUSERNAME179}
    clear_Item   ${PUSERNAME179}
    clear_Catalog   ${PUSERNAME179}
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    
    
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float1}=  twodigitfloat  ${price1}
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    ${price1float2}=  twodigitfloat  ${price2}
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    ${promoPrice2float}=  twodigitfloat  ${promoPrice2}
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence   
    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[0]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc3}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc3}=  FakerLibrary.Sentence   nb_words=3   
    ${price3}=  Random Int  min=50   max=300 
    ${price3}=  Convert To Number  ${price3}  1
    ${price1float3}=  twodigitfloat  ${price3}
    ${itemNameInLocal3}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice3}=  Random Int  min=10   max=${price3} 
    ${promoPrice3}=  Convert To Number  ${promoPrice3}  1
    ${promoPrice3float}=  twodigitfloat  ${promoPrice3}
    ${promoPrcnt3}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt3}=  twodigitfloat  ${promoPrcnt3}
    ${note3}=  FakerLibrary.Sentence   
    ${promoLabel3}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc3}    ${itemDesc3}    ${price3}    ${bool[0]}    ${itemName3}    ${itemNameInLocal3}    ${promotionalPriceType[1]}    ${promoPrice3}   ${promotionalPrcnt3}    ${note3}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel3}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc4}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc4}=  FakerLibrary.Sentence   nb_words=3   
    ${price4}=  Random Int  min=50   max=300 
    ${price4}=  Convert To Number  ${price4}  1
    ${price1float4}=  twodigitfloat  ${price4}
    ${itemNameInLocal4}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice4}=  Random Int  min=10   max=${price4} 
    ${promoPrice4}=  Convert To Number  ${promoPrice4}  1
    ${promoPrice4float}=  twodigitfloat  ${promoPrice4}
    ${promoPrcnt4}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt4}=  twodigitfloat  ${promoPrcnt4}
    ${note4}=  FakerLibrary.Sentence   
    ${promoLabel4}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc4}    ${itemDesc4}    ${price4}    ${bool[0]}    ${itemName4}    ${itemNameInLocal4}    ${promotionalPriceType[1]}    ${promoPrice4}   ${promotionalPrcnt4}    ${note4}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel4}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${shortDesc5}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc5}=  FakerLibrary.Sentence   nb_words=3   
    ${price5}=  Random Int  min=50   max=300 
    ${price5}=  Convert To Number  ${price5}  1
    ${price1float5}=  twodigitfloat  ${price5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice5}=  Random Int  min=10   max=${price5} 
    ${promoPrice5}=  Convert To Number  ${promoPrice5}  1
    ${promoPrice5float}=  twodigitfloat  ${promoPrice5}
    ${promoPrcnt5}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt5}=  twodigitfloat  ${promoPrcnt5}
    ${note5}=  FakerLibrary.Sentence   
    ${promoLabel5}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName5}    ${shortDesc5}    ${itemDesc5}    ${price5}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice5}   ${promotionalPrcnt5}    ${note5}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel5}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id5}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${startDate}=  get_date
    ${endDate}=  add_date  35      
    ${startDate1}=  get_date
    ${endDate1}=  add_date  35      
    ${noOfOccurance}=  Random Int  min=0   max=0
    ${sTime1}=   subtract_time  2  00
    ${eTime1}=   subtract_time  0  10
    ${sTime2}=  db.get_time
    ${eTime2}=  add_time   0  20 
    ${sTime3}=  add_time  0  25
    Set Suite Variable  ${sTime3}
    ${eTime3}=  add_time   0  40
    Set Suite Variable  ${eTime3} 
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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots3}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${catalog_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots3}
    ${pickUp_timeSlot}=  Create List  ${timeSlots2}   ${timeSlots3}
    ${homeDelivery_timeSlot}=  Create List  ${timeSlots1}   ${timeSlots2}   ${timeSlots3}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${catalog_timeSlot}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${pickUp_timeSlot}
    ${deliverySchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${homeDelivery_timeSlot}
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${deliverySchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList1}=  Create List   ${catalogItem1}  ${catalogItem2}

    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${CatalogStatus1}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
    Set Suite Variable  ${soon}    0
    Set Suite Variable  ${far}     35
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5

    Set Suite Variable  ${paymentType1}     ${AdvancedPaymentType[0]}
    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType1}   ${orderStatuses}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${item2_Id}=  Create Dictionary  itemId=${item_id2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList2}=  Create List   ${catalogItem1}  ${catalogItem2}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType1}   ${orderStatuses}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${paymentType2}     ${AdvancedPaymentType[1]}
    ${resp}=  Create Catalog For ShoppingList   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType2}   ${orderStatuses}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${item3_Id}=  Create Dictionary  itemId=${item_id3}
    ${item4_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${ItemList2}=  Create List   ${catalogItem3}  ${catalogItem4}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType2}   ${orderStatuses}   ${ItemList2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    Set Suite Variable  ${paymentType3}     ${AdvancedPaymentType[2]}
    ${ItemList3}=  Create List   ${catalogItem1}  ${catalogItem2}   ${catalogItem3}  ${catalogItem4}
    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType3}   ${orderStatuses}   ${ItemList3}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   autoConfirm=${boolean[1]}   catalogStatus=${CatalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId5}   ${resp.json()}
    ${resp}=  Get Order Catalog    ${CatalogId5}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c19_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname19}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname19}   ${resp.json()['lastName']}
    Set Suite Variable  ${c19_Uname}   ${resp.json()['userName']}
    ${cid19}=  get_id  ${CUSERNAME19}
    Set Suite Variable   ${cid19}
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email1}  ${C_firstName}${CUSERPH}.${test_mail}
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${code}=  Random Element    ${countryCodes}
    ${address1}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email1}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${code}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME19}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME19}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${Add_DAY1}=  add_date   1
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address1}   ${Add_DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid221}  ${orderid[0]}
    Set Suite Variable  ${order_Uid221}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid221}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no221}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order221_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY2}=  add_date   2
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY2}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid222}  ${orderid[0]}
    Set Suite Variable  ${order_Uid222}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid222}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no222}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order222_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY3}=  add_date   3
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId3}     ${bool[1]}    ${address1}   ${Add_DAY3}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid223}  ${orderid[0]}
    Set Suite Variable  ${order_Uid223}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid223}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no223}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order223_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order223_Advance}  ${bool[1]}  ${order_Uid223}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer223}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref223}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid223}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid223}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${Add_DAY4}=  add_date   4
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId4}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY4}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid224}  ${orderid[0]}
    Set Suite Variable  ${order_Uid224}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid224}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no224}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order224_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order224_Advance}  ${bool[1]}  ${order_Uid224}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer224}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref224}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid224}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid224}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY5}=  add_date   5
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId5}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY5}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid225}  ${orderid[0]}
    Set Suite Variable  ${order_Uid225}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid225}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no225}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order225_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order225_Advance}  ${bool[1]}  ${order_Uid225}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer225}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref225}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid225}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid225}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY11}=  add_date   11
    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${Add_DAY11}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid226}  ${orderid[0]}
    Set Suite Variable  ${order_Uid226}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid226}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no226}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order226_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY12}=  add_date   12
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY12}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid227}  ${orderid[0]}
    Set Suite Variable  ${order_Uid227}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid227}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no227}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order227_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY13}=  add_date   13
    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId3}     ${bool[1]}    ${Add_DAY13}    ${sTime3}    ${eTime3}    ${CUSERNAME19}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid228}  ${orderid[0]}
    Set Suite Variable  ${order_Uid228}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid228}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no228}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order228_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order228_Advance}  ${bool[1]}  ${order_Uid228}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer228}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref228}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid228}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid228}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY14}=  add_date   14
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId4}     ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY14}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid229}  ${orderid[0]}
    Set Suite Variable  ${order_Uid229}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid229}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no229}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order229_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order229_Advance}  ${bool[1]}  ${order_Uid229}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer229}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref229}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid229}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid229}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY15}=  add_date   15
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId5}    ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY15}    ${CUSERNAME19}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid230}  ${orderid[0]}
    Set Suite Variable  ${order_Uid230}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid230}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no230}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order230_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order230_Advance}  ${bool[1]}  ${order_Uid230}  ${pid1}  ${purpose[0]}  ${cid19}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer230}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref230}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid230}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid230}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c17_id}   ${resp.json()['id']}
    Set Suite Variable  ${fname17}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname17}   ${resp.json()['lastName']}
    Set Suite Variable  ${c17_Uname}   ${resp.json()['userName']}
    ${cid17}=  get_id  ${CUSERNAME17}
    Set Suite Variable   ${cid17}
    ${C_firstName2}=   FakerLibrary.first_name 
    ${C_lastName2}=   FakerLibrary.name 
    ${C_num2}    Random Int  min=123456   max=999999
    ${CUSERPH2}=  Evaluate  ${CUSERNAME}+${C_num2}
    Set Test Variable  ${C_email2}  ${C_firstName2}${CUSERPH2}.${test_mail}
    ${homeDeliveryAddress2}=   FakerLibrary.name 
    ${city2}=  FakerLibrary.city
    ${landMark2}=  FakerLibrary.Sentence   nb_words=2 
    ${code2}=  Random Element    ${countryCodes}
    ${address2}=  Create Dictionary   phoneNumber=${CUSERPH2}    firstName=${C_firstName2}   lastName=${C_lastName2}   email=${C_email2}    address=${homeDeliveryAddress2}   city=${city2}   postalCode=${C_num2}    landMark=${landMark2}   countryCode=${code2}
 

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    Set Suite Variable  ${item_quantity1}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME17}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME17}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${Add_DAY1}=  add_date   1
    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${Add_DAY1}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid231}  ${orderid[0]}
    Set Suite Variable  ${order_Uid231}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid231}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no231}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order231_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY2}=  add_date   2
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY2}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid232}  ${orderid[0]}
    Set Suite Variable  ${order_Uid232}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid232}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no232}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order232_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY3}=  add_date   3
    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId3}     ${bool[1]}    ${Add_DAY3}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid233}  ${orderid[0]}
    Set Suite Variable  ${order_Uid233}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid233}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no233}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order233_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order233_Advance}  ${bool[1]}  ${order_Uid233}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer233}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref233}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid233}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid233}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY4}=  add_date   4
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId4}     ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY4}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid234}  ${orderid[0]}
    Set Suite Variable  ${order_Uid234}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid234}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no234}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order234_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order234_Advance}  ${bool[1]}  ${order_Uid234}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer234}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref234}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid234}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid234}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY5}=  add_date   5
    ${resp}=   Create Order For Pickup    ${cookie}  ${accId3}    ${self}    ${CatalogId5}     ${bool[1]}    ${sTime3}    ${eTime3}   ${Add_DAY5}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid235}  ${orderid[0]}
    Set Suite Variable  ${order_Uid235}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid235}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no235}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order235_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order235_Advance}  ${bool[1]}  ${order_Uid235}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer235}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref235}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid235}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid235}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY21}=  add_date   21
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId1}     ${bool[1]}    ${address1}   ${Add_DAY21}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid236}  ${orderid[0]}
    Set Suite Variable  ${order_Uid236}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid236}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no236}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order236_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY22}=  add_date   22
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId2}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY22}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid237}  ${orderid[0]}
    Set Suite Variable  ${order_Uid237}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid237}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no237}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order237_Advance}  ${resp.json()['advanceAmountToPay']}

    ${Add_DAY23}=  add_date   23
    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}  ${accId3}   ${caption}    ${self}    ${CatalogId3}     ${bool[1]}    ${address1}   ${Add_DAY23}    ${sTime3}    ${eTime3}    ${CUSERNAME17}    ${email}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid238}  ${orderid[0]}
    Set Suite Variable  ${order_Uid238}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid238}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no238}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order238_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order238_Advance}  ${bool[1]}  ${order_Uid238}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer238}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref238}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid238}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid238}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY24}=  add_date   24
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId4}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY24}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid239}  ${orderid[0]}
    Set Suite Variable  ${order_Uid239}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid239}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no239}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order239_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order239_Advance}  ${bool[1]}  ${order_Uid239}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer239}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref239}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid239}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid239}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${Add_DAY25}=  add_date   25
    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId3}    ${self}    ${CatalogId5}     ${bool[1]}    ${address1}    ${sTime3}    ${eTime3}   ${Add_DAY25}    ${CUSERNAME17}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity1}  ${item_id3}  ${item_quantity1}  ${item_id4}  ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary items  ${resp.json()}
    Set Suite Variable  ${orderid240}  ${orderid[0]}
    Set Suite Variable  ${order_Uid240}  ${orderid[1]}
    ${resp}=   Get Order By Id    ${accId3}   ${order_Uid240}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no240}  ${resp.json()['orderNumber']}
    Set Suite Variable  ${order240_Advance}  ${resp.json()['advanceAmountToPay']}

    ${resp}=  Make payment Consumer Mock  ${order240_Advance}  ${bool[1]}  ${order_Uid240}  ${pid1}  ${purpose[0]}  ${cid17}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer240}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref240}   ${resp.json()['paymentRefId']}
    sleep   02s
    # ${resp}=  Get Bill By consumer  ${order_Uid240}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=   Get Order By Id   ${accId3}  ${order_Uid240}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid19}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC19}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c19_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c19_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c19_dob}   ${resp.json()[0]['dob']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid17}  ${resp.json()[0]['id']}
    Set Suite Variable  ${cons_JC17}  ${resp.json()[0]['jaldeeConsumer']}
    Set Suite Variable  ${c17_jId}   ${resp.json()[0]['jaldeeId']}
    Set Suite Variable  ${c17_gender}   ${resp.json()[0]['gender']}
    Set Suite Variable  ${c17_dob}   ${resp.json()[0]['dob']}


    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Add_DAY1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY1}    ${Add_DAY1} [${sTime3} To ${eTime3}]

    ${Add_DAY2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY2}    ${Add_DAY2} [${sTime3} To ${eTime3}]

    ${Add_DAY3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY3}    ${Add_DAY3} [${sTime3} To ${eTime3}]

    ${Add_DAY4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY4}    ${Add_DAY4} [${sTime3} To ${eTime3}]

    ${Add_DAY5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY5}    ${Add_DAY5} [${sTime3} To ${eTime3}]

    ${Add_DAY11} =	Convert Date	${Add_DAY11}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY11}    ${Add_DAY11} [${sTime3} To ${eTime3}]

    ${Add_DAY12} =	Convert Date	${Add_DAY12}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY12}    ${Add_DAY12} [${sTime3} To ${eTime3}]

    ${Add_DAY13} =	Convert Date	${Add_DAY13}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY13}    ${Add_DAY13} [${sTime3} To ${eTime3}]

    ${Add_DAY14} =	Convert Date	${Add_DAY14}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY14}    ${Add_DAY14} [${sTime3} To ${eTime3}]

    ${Add_DAY15} =	Convert Date	${Add_DAY15}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY15}    ${Add_DAY15} [${sTime3} To ${eTime3}]

    ${Add_DAY21} =	Convert Date	${Add_DAY21}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY21}    ${Add_DAY21} [${sTime3} To ${eTime3}]

    ${Add_DAY22} =	Convert Date	${Add_DAY22}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY22}    ${Add_DAY22} [${sTime3} To ${eTime3}]

    ${Add_DAY23} =	Convert Date	${Add_DAY23}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY23}    ${Add_DAY23} [${sTime3} To ${eTime3}]

    ${Add_DAY24} =	Convert Date	${Add_DAY24}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY24}    ${Add_DAY24} [${sTime3} To ${eTime3}]

    ${Add_DAY25} =	Convert Date	${Add_DAY25}	result_format=%d/%m/%Y
    Set Suite Variable   ${Order_DAY25}    ${Add_DAY25} [${sTime3} To ${eTime3}]

    ${TODAY}=  get_date
    Set Suite Variable   ${TODAY}
    ${DATE1}=  add_date    1
    Set Suite Variable   ${DATE1}
    ${DATE7}=  add_date    7
    Set Suite Variable   ${DATE7}
    ${DATE30}=  add_date   30
    Set Suite Variable   ${DATE30}

    ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    10                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30}

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no221}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no222}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no223}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no224}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    ${order224_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no225}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['1']}    ${Order_DAY21}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['6']}    ${order_no236}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['1']}    ${Order_DAY22}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['6']}    ${order_no237}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['1']}    ${Order_DAY23}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['6']}    ${order_no238}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['1']}    ${Order_DAY24}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['6']}    ${order_no239}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['9']}    ${order239_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['1']}    ${Order_DAY25}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['6']}    ${order_no240}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['9']}    ${order240_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['12']}   ${orderMode[0]}


    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    5                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE7}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no221}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no222}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no223}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no224}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    ${order224_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no225}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}


    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${TODAY}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
   
    
JD-TC-OrderReport-23
    [Documentation]     Generate report of Store Pickup orders

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    
    ${filter}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[1]}

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    10 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no231}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no232}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no233}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no234}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    ${order234_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no235}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    ${order235_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['1']}    ${Order_DAY11}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['6']}    ${order_no226}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['1']}    ${Order_DAY12}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['6']}    ${order_no227}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['1']}    ${Order_DAY13}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['6']}    ${order_no228}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['1']}    ${Order_DAY14}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['6']}    ${order_no229}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['9']}    ${order229_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['1']}    ${Order_DAY15}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['6']}    ${order_no230}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['9']}    ${order230_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['12']}   ${orderMode[0]}

    

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    5 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE7}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no231}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no232}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no233}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no234}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    ${order234_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no235}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    ${order235_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}
    

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${TODAY}               

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode
    
    change_system_date   7
    ${LAST_WEEK_DAY1}=  subtract_date  7
    ${LAST_WEEK_DAY7}=  subtract_date  1

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${filter}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[1]}
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    5 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no235}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order235_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no234}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    ${order234_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no233}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no232}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no231}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}        # Mode
           
    resetsystem_time



JD-TC-OrderReport-24
    [Documentation]     Generate order report using order number as filter

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    
    ${filter}=  Create Dictionary   orderNumber-eq=${order_no240}
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1                    
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30} 

    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['1']}   Order Date            # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['2']}   Customer ID           # CustomerId
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['3']}   Customer Name         # CustomerName
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['4']}   Customer Phone        # CustomerPhone
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['5']}   Catalog Name          # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['6']}   Order Number          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['7']}   Mode Of Delivery      # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['8']}   Status                # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['9']}   Paid Amount           # Paid Amount 
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['10']}  Refunded Amount       # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['11']}  Bill Payment Status   # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['columns']['12']}  Mode                  # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY25}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no240}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order240_Advance}                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE7}



    ${filter}=  Create Dictionary   orderNumber-eq=${order_no230}
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30}               
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY15}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no230}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order230_Advance}                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode


    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE7}

    change_system_date   1
    ${ORDER_DATE}=  get_date
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${filter}=  Create Dictionary   ${OrderTypeFilters[0]}=${bool[1]}
    # ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${filter}=  Create Dictionary   ${OrderTypeFilters[1]}=${bool[1]}
    # ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   orderNumber-eq=${order_no221}
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${ORDER_DATE}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}          # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no221}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode

    
    change_system_date   1
    ${LAST_WEEK_DAY1}=  subtract_date  7
    ${LAST_WEEK_DAY7}=  subtract_date  1

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${filter}=  Create Dictionary   orderNumber-eq=${order_no221}
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}          # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no221}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode

    resetsystem_time


JD-TC-OrderReport-25
    [Documentation]     Generate order report using order status as filter

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${filter}=  Create Dictionary   orderStatus-eq=Order Received
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30}


    ${filter}=  Create Dictionary   orderStatus-eq=Order Confirmed
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    20 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${DATE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${DATE30}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no221}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode
           
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no231}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no222}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no232}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no223}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['6']}    ${order_no233}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['6']}    ${order_no224}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['9']}    ${order224_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['6']}    ${order_no234}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['9']}    ${order234_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['6']}    ${order_no225}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['6']}    ${order_no235}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['9']}    ${order235_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['1']}    ${Order_DAY11}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['6']}    ${order_no226}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][10]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['1']}    ${Order_DAY12}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['6']}    ${order_no227}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][11]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['1']}    ${Order_DAY13}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['6']}    ${order_no228}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][12]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['1']}    ${Order_DAY14}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['6']}    ${order_no229}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['9']}    ${order229_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][13]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['1']}    ${Order_DAY15}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['6']}    ${order_no230}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['9']}    ${order230_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][14]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['1']}    ${Order_DAY21}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['6']}    ${order_no236}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][15]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['1']}    ${Order_DAY22}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['6']}    ${order_no237}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][16]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['1']}    ${Order_DAY23}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['6']}    ${order_no238}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][17]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['1']}    ${Order_DAY24}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['6']}    ${order_no239}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['9']}    ${order239_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][18]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['1']}    ${Order_DAY25}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['6']}    ${order_no240}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['9']}    ${order240_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][19]['12']}   ${orderMode[0]}

    change_system_date   6
    ${LAST_WEEK_DAY1}=  subtract_date  7
    ${LAST_WEEK_DAY7}=  subtract_date  1

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId111}'  # ConfirmationId
    #     ...    Run Keywords
    
    #     ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
    #     ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
    #     ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
    #     ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
    #     ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
    #     ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
    #     ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
    #     ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
    #         # ...    AND  Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    #     ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId112}'  # ConfirmationId
    #     ...    Run Keywords

    #     ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
    #     ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
    #     ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
    #     ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
    #     ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
    #     ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
    #     ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
    #     ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            
    
    ${filter}=  Create Dictionary   orderStatus-eq=Order Confirmed
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    10 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}
    Run Keyword IF  '${resp.json()['reportContent']['data'][0]['6']}' == '${order_no235}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   0
    ...    AND   Set Test Variable   ${j}   1 

    ...    ELSE IF   '${resp.json()['reportContent']['data'][1]['6']}' == '${order_no235}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   1
    ...    AND   Set Test Variable   ${j}   0

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no235}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${order235_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['6']}    ${order_no225}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['12']}   ${orderMode[0]}

    Run Keyword IF  '${resp.json()['reportContent']['data'][2]['6']}' == '${order_no234}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   2
    ...    AND   Set Test Variable   ${j}   3 

    ...    ELSE IF   '${resp.json()['reportContent']['data'][3]['6']}' == '${order_no234}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   3
    ...    AND   Set Test Variable   ${j}   2

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no234}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    ${order234_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['1']}    ${Order_DAY4}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['6']}    ${order_no224}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['9']}    ${order224_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['12']}   ${orderMode[0]}

    Run Keyword IF  '${resp.json()['reportContent']['data'][4]['6']}' == '${order_no233}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   4
    ...    AND   Set Test Variable   ${j}   5 

    ...    ELSE IF   '${resp.json()['reportContent']['data'][5]['6']}' == '${order_no233}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   5
    ...    AND   Set Test Variable   ${j}   4

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no233}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}
 
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['1']}    ${Order_DAY3}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['6']}    ${order_no223}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['12']}   ${orderMode[0]}

    Run Keyword IF  '${resp.json()['reportContent']['data'][6]['6']}' == '${order_no232}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   6
    ...    AND   Set Test Variable   ${j}   7 

    ...    ELSE IF   '${resp.json()['reportContent']['data'][7]['6']}' == '${order_no232}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   7
    ...    AND   Set Test Variable   ${j}   6

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no232}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['1']}    ${Order_DAY2}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['6']}    ${order_no222}           # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['12']}   ${orderMode[0]}        # Mode
      
    Run Keyword IF  '${resp.json()['reportContent']['data'][8]['6']}' == '${order_no231}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   8
    ...    AND   Set Test Variable   ${j}   9 

    ...    ELSE IF   '${resp.json()['reportContent']['data'][9]['6']}' == '${order_no231}'  # Order Number
    ...    Run Keywords
    ...    Set Test Variable   ${i}   9
    ...    AND   Set Test Variable   ${j}   8

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['6']}    ${order_no231}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${i}]['12']}   ${orderMode[0]}        # Mode
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['1']}    ${Order_DAY1}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['6']}    ${order_no221}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][${j}]['12']}   ${orderMode[0]}        # Mode
    
   

    ${NEXT_MONTH_DAY1}=   add_date   1
    ${NEXT_MONTH_DAY30}=  add_date  30
    ${filter}=  Create Dictionary   orderStatus-eq=Order Confirmed
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Next 30 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    10 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${NEXT_MONTH_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${NEXT_MONTH_DAY30}

    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY11}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no226}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}
  
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}    ${Order_DAY12}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}    ${order_no227}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['1']}    ${Order_DAY13}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['6']}    ${order_no228}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][2]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['1']}    ${Order_DAY14}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['6']}    ${order_no229}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['9']}    ${order229_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][3]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['1']}    ${Order_DAY15}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['6']}    ${order_no230}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['7']}    ${ModeOfDelivery[1]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['9']}    ${order230_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][4]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['1']}    ${Order_DAY21}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['5']}    ${catalogName1}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['6']}    ${order_no236}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][5]['12']}   ${orderMode[0]}
    
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['1']}    ${Order_DAY22}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['5']}    ${catalogName2}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['6']}    ${order_no237}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][6]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['1']}    ${Order_DAY23}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['5']}    ${catalogName3}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['6']}    ${order_no238}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['9']}    0.0                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['11']}   ${BillStatus[0]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][7]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['1']}    ${Order_DAY24}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['5']}    ${catalogName4}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['6']}    ${order_no239}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['9']}    ${order239_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['11']}   ${BillStatus[1]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][8]['12']}   ${orderMode[0]}

    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['1']}    ${Order_DAY25}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['2']}    ${c17_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['3']}    ${c17_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['4']}    +91 ${CUSERNAME17}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['6']}    ${order_no240}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['8']}    Order Confirmed        # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['9']}    ${order240_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][9]['12']}   ${orderMode[0]}
    
    resetsystem_time


JD-TC-OrderReport-26
    [Documentation]     Change order ststus and Generate order report using order status as filter
    change_system_date   5
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}
    ${ORDER_DATE}=  get_date

    ${filter}=  Create Dictionary   orderStatus-eq=Order Received
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report                 
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    0 
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${ORDER_DATE}


    ${resp}=  Change Order Status   ${order_Uid225}   ${orderStatuses[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid225}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}

    ${filter}=  Create Dictionary   orderStatus-eq=Order Received
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report                 
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${ORDER_DATE}               
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY5}          # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no225}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Order Received         # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode


    ${resp}=  Change Order Status   ${order_Uid225}   ${orderStatuses[8]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid225}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[8]}

    ${filter}=  Create Dictionary   orderStatus-eq=Ready For Delivery
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${ORDER_DATE}               
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY5}          # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no225}         # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Ready For Delivery     # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order225_Advance}    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode


    ${resp}=  Change Order Status   ${order_Uid225}   ${orderStatuses[9]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  01s
    ${resp}=  Get Order Status Changes by uid    ${order_Uid225}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${orderStatuses[2]}
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${orderStatuses[0]}
    Should Be Equal As Strings  ${resp.json()[2]['orderStatus']}         ${orderStatuses[8]}
    Should Be Equal As Strings  ${resp.json()[3]['orderStatus']}         ${orderStatuses[9]}
    
    ${filter}=  Create Dictionary   orderStatus-eq=Completed
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[0]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Today      
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['date']}     ${ORDER_DATE}               
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no225}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Completed             # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order225_Advance}                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode


    change_system_date   3
    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${LAST_WEEK_DAY1}=  subtract_date  7 
    ${LAST_WEEK_DAY7}=  subtract_date  1
    ${filter}=  Create Dictionary   orderStatus-eq=Completed
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[1]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}   Last 7 days       
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                    Order Report         
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}    1 
    Should Be Equal As Strings  ${resp.json()['reportContent']['from']}     ${LAST_WEEK_DAY1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['to']}       ${LAST_WEEK_DAY7}               
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}    ${Order_DAY5}         # Order Date
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}    ${c19_jId}             # Customer Id
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}    ${c19_Uname}           # Customer Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['4']}    +91 ${CUSERNAME19}     # Customer Phone
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}    ${catalogName5}        # Catalog Name
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}    ${order_no225}          # Order Number
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}    ${ModeOfDelivery[0]}   # Mode Of Delivery
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['8']}    Completed             # Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['9']}    ${order225_Advance}                    # Paid Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['10']}   0.0                    # Refunded Amount
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['11']}   ${BillStatus[2]}       # Bill Payment Status
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['12']}   ${orderMode[0]}        # Mode

    resetsystem_time


JD-TC-OrderReport-27
    [Documentation]     Generate order report using order mode as filter

    ${resp}=  ProviderLogin  ${PUSERNAME179}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    ${accId3}=  get_acc_id  ${PUSERNAME179}

    ${filter}=  Create Dictionary   orderMode-eq=ONLINE_ORDER
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${filter}=  Create Dictionary   orderMode-eq=WALKIN_ORDER
    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[4]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Report REST details  ${ReportType}   ${DateCategory[2]}   ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200










































































































































    # Set Test Variable  ${status-eq}               SUCCESS
    # Set Test Variable  ${reportType}              ORDER
    # Set Test Variable  ${reportDateCategory}      NEXT_WEEK

    # ${filter}=  Create Dictionary   homeDelivery-eq=${bool[1]}   
    # ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # # Set Suite Variable  ${ReportId_c10}      ${resp.json()['reportRequestId']}
    # # Should Be Equal As Strings  ${jid_c10}   ${resp.json()['reportContent']['reportHeader']['Customer Id']}
    # Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    # Should Be Equal As Strings  Order Report         ${resp.json()['reportContent']['reportName']}
    # Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    # # Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}



    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['1']}    ${Order_Date1}        # Order Date
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['2']}    ${c19_jId}            # Customer Id
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['3']}    ${c19_Uname}          # Customer Name
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['4']}    +91 ${CUSERNAME19}    # Customer Phone
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['5']}    ${catalogName1}       # Catalog Name
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['6']}    ${order_no1}          # Order Number
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['7']}    ${ModeOfDelivery[0]}  # Mode Of Delivery
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['8']}    Order Received        # Status
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['9']}    0.0                   # Paid Amount
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['10']}   0.0                   # Refunded Amount
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['11']}   ${BillStatus[0]}      # Bill Payment Status
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][]['12']}   ${orderMode[0]}       # Mode