*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Analytics Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${count}       ${10}
${count1}      ${15}
${count2}      ${4}
${self}        0
${CUSERPH}     ${CUSERNAME}
${start}       11
${def_amt}     0.0

*** Test Cases ***

JD-TC-PaymentLevelAnalyticsforOrder-1

    [Documentation]   take online order(home delivery and pickup) for a provider by 10 consumers and do the prepayment and check account level analytics for ORDER_PRE_PAYMENT_COUNT matrix.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+7857710
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${acc_id}  ${resp.json()['id']}

    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    Set Suite Variable  ${PUSERNAME_A}

    ${pid}=  get_acc_id  ${PUSERNAME_A}
    Set Suite Variable  ${pid}
    
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME_A}.${test_mail}

    ${resp}=  Update Email   ${acc_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_A}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_A}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   4  45
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

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable   ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  add_date   11
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_time   3  30 
    Set Suite Variable  ${eTime1}  
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge}
 
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
    ${catalogSchedule1}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule1}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    ${homeDelivery1}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    
    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}   ${orderStatuses[4]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[8]}   ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}  
    Set Suite Variable   ${StatusList}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    Set Test Variable  ${paymentType1}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=1   max=100
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1

    ${far1}=  Random Int  min=0  max=0
   
    ${soon1}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${catalogName1}=   FakerLibrary.name  
    ${catalogDesc1}=   FakerLibrary.name 

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc1}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery1}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far1}   howSoon=${soon1}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${catalogName3}=   FakerLibrary.name  
    ${catalogDesc3}=   FakerLibrary.name 

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc3}   ${catalogSchedule}   ${orderType}   ${paymentType1}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${catalogName4}=   FakerLibrary.name  
    ${catalogDesc4}=   FakerLibrary.name 

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc4}   ${catalogSchedule}   ${orderType}   ${paymentType1}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery1}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${order_ids}=  Create List
    Set Suite Variable   ${order_ids}

    ${order_ids1}=  Create List
    Set Suite Variable   ${order_ids1}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}
    ${DAY1}=  add_date   12
    Set Suite Variable  ${DAY1}

    ${DAY2}=  add_date   13
    Set Suite Variable  ${DAY2}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

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

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt}  ${orderid[1]}

        Append To List   ${order_ids}  ${orderid${a}}

        ${resp}=   Create Order For Pickup   ${cookie}   ${pid}    ${self}    ${CatalogId4}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity2} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid1${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt1}   ${orderid[1]}

        Append To List   ${order_ids1}  ${orderid1${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END   

    Log Many   ${prepayAmt}  ${prepayAmt1}  ${count}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Order By Id  ${pid}  ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[1]}   orderMode=${order_mode[1]}

        ${resp}=   Get Order By Id  ${pid}  ${orderid1${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[1]}   orderMode=${order_mode[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log Many   ${order_ids}  ${order_ids1}

    
    FOR   ${a}  IN RANGE   ${count}
        
        # ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # # Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        # Set Test Variable  ${cid${a}}   ${resp.json()[0]['jaldeeConsumer']}

        
        # ${resp}=  Provider Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()['id']}
    

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt}  ${purpose[0]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  billPaymentStatus=${paymentStatus[1]}  
        Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${prepayAmt}   
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}   orderInternalStatus=${orderInternalStatus[0]}   orderMode=${order_mode[1]}

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt1}  ${purpose[0]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  billPaymentStatus=${paymentStatus[1]} 
        Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${prepayAmt1}   
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[0]}   orderMode=${order_mode[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${prepayment_count}=   Evaluate  len($order_ids) + len($order_ids1)
    Set Suite Variable   ${prepayment_count}

    Log Many   ${prepayAmt}  ${prepayAmt1}  ${count}

    ${home_pre_total}=   Evaluate   ${prepayAmt} * ${count}
    ${pickup_pre_total}=  Evaluate   ${prepayAmt1} * ${count}
    ${pre_payment_total}=  Evaluate  ${pickup_pre_total} + ${home_pre_total}
    Set Suite Variable   ${pre_payment_total}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${DAY}=  get_date
    Set Suite Variable   ${DAY}
    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_COUNT']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${prepayment_count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_TOTAL']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Numbers  ${resp.json()['metricValues'][0]['amount']}    ${pre_payment_total}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_TOTAL']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentLevelAnalyticsforOrder-2

    [Documentation]   take online order(home delivery and pickup) for a provider by 10 consumers and do the prepayment and then bill payment
    ...  and check account level analytics for ORDER_BILL_PAYMENT_COUNT matrix.
    
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}

    ${order_ids2}=  Create List
    Set Suite Variable   ${order_ids2}

    ${order_ids3}=  Create List
    Set Suite Variable   ${order_ids3}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

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

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt}  ${orderid[1]}

        Append To List   ${order_ids2}  ${orderid${a}}

        ${resp}=   Create Order For Pickup   ${cookie}   ${pid}    ${self}    ${CatalogId4}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity2} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid1${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt1}   ${orderid[1]}

        Append To List   ${order_ids3}  ${orderid1${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Order By Id  ${pid}  ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Order By Id  ${pid}  ${orderid1${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log Many   ${order_ids2}   ${order_ids3}
    
    FOR   ${a}  IN RANGE   ${count}
        
        # ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        # ${resp}=  Provider Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()['id']}
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt}  ${purpose[0]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt1}  ${purpose[0]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${amountDue}=  Evaluate  ${item1_total} + ${deliveryCharge} - ${prepayAmt}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    
    ${item1_total1}=  Evaluate  ${item_quantity2} * ${promoPrice1}
    ${item1_total1}=  Convert To twodigitfloat  ${item1_total1}
    ${amountDue1}=  Evaluate  ${item1_total1} - ${prepayAmt1}
    ${amountDue1}=  Convert To twodigitfloat  ${amountDue1}

    FOR   ${a}  IN RANGE   ${count}
        
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue1}  ${purpose[1]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${billpayment_count}=   Evaluate  len($order_ids2) + len($order_ids3)
    Set Suite Variable   ${billpayment_count}

    ${home_bill_total}=   Evaluate   ${amountDue} * ${count}
    ${pickup_bill_total}=  Evaluate   ${amountDue1} * ${count}
    ${bill_payment_total}=  Evaluate  ${home_bill_total} + ${pickup_bill_total}
    Set Suite Variable   ${bill_payment_total}


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_COUNT']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${billpayment_count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}
    
    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${bill_payment_total}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}

JD-TC-PaymentLevelAnalyticsforOrder-3

    [Documentation]   take online order(home delivery and pickup) for a provider by 10 consumers and do the prepayment and then bill payment with tax
    ...  and check account level analytics for ORDER_BILL_PAYMENT_COUNT matrix.
    
    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}

    ${order_ids}=  Create List
    Set Test Variable   ${order_ids}

    ${order_ids1}=  Create List
    Set Test Variable   ${order_ids1}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

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

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt}  ${orderid[1]}

        Append To List   ${order_ids}  ${orderid${a}}

        ${resp}=   Create Order For Pickup   ${cookie}   ${pid}    ${self}    ${CatalogId4}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity2} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid1${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt1}   ${orderid[1]}

        Append To List   ${order_ids1}  ${orderid1${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Order By Id  ${pid}  ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Order By Id  ${pid}  ${orderid1${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log Many   ${order_ids}   ${order_ids1}
    
    FOR   ${a}  IN RANGE   ${count}
        
        # ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        # ${resp}=  Provider Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()['id']}
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt}  ${purpose[0]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt1}  ${purpose[0]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge} - ${prepayAmt}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}
    
    ${item1_total1}=  Evaluate  ${item_quantity2} * ${promoPrice1}
    ${item1_total1}=  Convert To twodigitfloat  ${item1_total1}
    ${totalTaxAmount}=  Evaluate  ${item1_total1} * ${gstpercentage[3]} / 100
    ${amountDue1}=  Evaluate  ${item1_total1} + ${totalTaxAmount} - ${prepayAmt1}
    ${amountDue1}=  Convert To twodigitfloat  ${amountDue1}

    FOR   ${a}  IN RANGE   ${count}
        
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue1}  ${purpose[1]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${billpayment_count}=   Evaluate  len($order_ids) + len($order_ids1)
    Set Test Variable   ${billpayment_count}

    ${home_bill_total}=   Evaluate   ${amountDue} * ${count}
    ${pickup_bill_total}=  Evaluate   ${amountDue1} * ${count}
    ${bill_payment_total}=  Evaluate  ${home_bill_total} + ${pickup_bill_total}
    Set Test Variable   ${bill_payment_total}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_COUNT']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${billpayment_count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}
    
    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${bill_payment_total}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}

JD-TC-PaymentLevelAnalyticsforOrder-4

    [Documentation]   take walkin order(home delivery and pickup) for a provider by 10 consumers and do the prepayment and 
    ...   check account level analytics for ORDER_PRE_PAYMENT_COUNT matrix.
    
    ${order_ids}=  Create List
    Set Test Variable   ${order_ids}

    ${order_ids1}=  Create List
    Set Test Variable   ${order_ids1}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_A}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

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
        ${orderNote}=    FakerLibrary.name 

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        
        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId3}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        # ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt}   ${orderid[1]}
     
        Append To List   ${order_ids}  ${orderid${a}}
        
        ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId4}   ${boolean[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        # ${resp}=   Create Order For Pickup   ${cookie}   ${pid}    ${self}    ${CatalogId4}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY2}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity2} 
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid1${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt1}   ${orderid[1]}

        Append To List   ${order_ids1}  ${orderid1${a}}

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Order By Id  ${pid}  ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[1]}   orderMode=${order_mode[1]}

        ${resp}=   Get Order By Id  ${pid}  ${orderid1${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[1]}   orderMode=${order_mode[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log Many   ${order_ids}  ${order_ids1}

    
    FOR   ${a}  IN RANGE   ${count}
        
        # ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        # ${resp}=  Provider Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()['id']}
    

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt}  ${purpose[0]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  billPaymentStatus=${paymentStatus[1]}  
        Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${prepayAmt}   
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}   orderInternalStatus=${orderInternalStatus[0]}   orderMode=${order_mode[1]}

        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt1}  ${purpose[0]}  ${orderid1${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid1${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  billPaymentStatus=${paymentStatus[1]} 
        Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}   ${prepayAmt1}   
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid1${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}    orderInternalStatus=${orderInternalStatus[0]}   orderMode=${order_mode[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${prepayment_count}=   Evaluate  len($order_ids) + len($order_ids1)
    Set Suite Variable   ${prepayment_count}

    ${home_pre_total}=   Evaluate   ${prepayAmt} * ${count}
    ${pickup_pre_total}=  Evaluate   ${prepayAmt1} * ${count} 
    ${pre_payment_total}=  Evaluate  ${pickup_pre_total} + ${home_pre_total}
    Set Suite Variable   ${pre_payment_total}


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${DAY}=  get_date
    Set Suite Variable   ${DAY}
    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_COUNT']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${prepayment_count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_TOTAL']}  dateFrom=${DAY}  dateTo=${DAY}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${pre_payment_total}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_PRE_PAYMENT_TOTAL']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY}



# *** comment ***
JD-TC-PaymentLevelAnalyticsforOrder-6

    [Documentation]   take order(home delivery) for a provider by 10 consumers and do the prepayment and then bill payment with tax
    ...  and check account level analytics for ORDER_BILL_PAYMENT_TOTAL matrix.
    
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

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

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
        Set Test Variable  ${prepayAmt}  ${orderid[1]}

        Append To List   ${order_ids}  ${orderid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Order By Id  ${pid}  ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${order_ids}
    
    FOR   ${a}  IN RANGE   ${count}
        
        # ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        # Log   ${resp.json()}
        # Should Be Equal As Strings    ${resp.status_code}    200
        
        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        # ${resp}=  Provider Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()['id']}
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${prepayAmt}  ${purpose[0]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END
    
    ${item1_total}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${item1_total}=  Convert To twodigitfloat  ${item1_total}
    ${totalTaxAmount}=  Evaluate  ${item1_total} * ${gstpercentage[3]} / 100
    ${amountDue}=  Evaluate  ${item1_total} + ${totalTaxAmount} + ${deliveryCharge} - ${prepayAmt}
    ${amountDue}=  Convert To twodigitfloat  ${amountDue}

    FOR   ${a}  IN RANGE   ${count}
        
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    
        ${resp}=  Make payment Consumer Mock  ${pid}  ${amountDue}  ${purpose[1]}  ${orderid${a}}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   02s
        ${resp}=  Get Bill By consumer  ${orderid${a}}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
       
        sleep   1s
        ${resp}=   Get Order By Id   ${pid}  ${orderid${a}}   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${billpayment_count}=   Evaluate  len($order_ids)
    Set Suite Variable   ${billpayment_count}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${billpayment_count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['ORDER_BILL_PAYMENT_TOTAL']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
