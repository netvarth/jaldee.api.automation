*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Analytics Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
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


JD-TC-AccountLevelAnalyticsforOrder-1

    [Documentation]   take order(home delivery) for a provider by 10 consumers for the same date and check account level analytics for ONLINE_ORDER matrix.
    
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-2}
    Set Suite Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+7857711
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
    
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME_A}.ynwtest@netvarth.com

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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
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

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${advanceAmount}=  Random Int  min=1   max=1000
   
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
    
    ${order_ids}=  Create List
    Set Suite Variable   ${order_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

        ${DAY1}=  add_date   12
        Set Suite Variable  ${DAY1}
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Test Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
        ${EMPTY_List}=  Create List
        Set Suite Variable  ${EMPTY_List}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

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
    
    ${online_order_len}=   Evaluate  len($order_ids)
    Set Suite Variable   ${online_order_len}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  05m
       
    ${resp}=  Flush Analytics Data to DB
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['BRAND_NEW_ORDERS']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalyticsforOrder-2

    [Documentation]   take order for a provider by 4 consumers for different date and check account level analytics for ONLINE_ORDER matrix.
    
    ${order_ids1}=  Create List
    Set Suite Variable   ${order_ids1}

    FOR   ${a}  IN RANGE   ${count2}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200
        
        ${days}=  Create List
        Set Suite Variable   ${days}

        FOR   ${x}  IN RANGE   ${start}   ${count1}
            ${DAY}=  add_date   ${x}
            Append To List   ${days}  ${DAY}
        END
        Log   ${days}
        ${len}=  Get Length  ${days}

        Set Test Variable   ${DAY1}   ${days[${a}]}
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Test Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
    
        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids1}  ${orderid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
    
    END   

    FOR   ${a}  IN RANGE    ${count2}
    
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

    Log List   ${order_ids1}
    
    ${online_order_len1}=   Evaluate  len($order_ids) + len($order_ids1) - 3
    Set Suite Variable   ${online_order_len1}

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
   
    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}  dateFrom=${days[0]}  dateTo=${days[${len}-1]}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${days[3]}
    
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}     1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['dateFor']}   ${days[2]}

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][2]['value']}     ${online_order_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][2]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][2]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][2]['dateFor']}   ${days[1]}

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][3]['value']}     1
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][3]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][3]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][3]['dateFor']}   ${days[0]}


JD-TC-AccountLevelAnalyticsforOrder-3

    [Documentation]   take order(pickup) for a provider by 10 consumers for the same date and check account level analytics for ONLINE_ORDER matrix.
    

    ${order_ids2}=  Create List
    Set Suite Variable   ${order_ids2}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200

        ${DAY1}=  add_date   12
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
       
        ${resp}=   Create Order For Pickup   ${cookie}   ${pid}    ${self}    ${CatalogId1}   ${bool[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids2}  ${orderid${a}}

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

    Log List   ${order_ids2}
    
    ${online_order_len2}=   Evaluate  ${online_order_len1} + len($order_ids2) 
    Set Suite Variable   ${online_order_len2}

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ONLINE_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-4

    [Documentation]   take order(home delivery) for a provider by 10 consumers for the same date and check account level analytics for WALK_IN_ORDER matrix.
    
    ${order_ids3}=  Create List
    Set Suite Variable   ${order_ids3}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
      
        ${DAY1}=  add_date   12
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Test Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Test Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Test Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_A}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids3}  ${orderid${a}}

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=   Get Order by uid   ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${order_ids3}
    
    ${walkin_order_len}=   Evaluate   len($order_ids3) 
    Set Suite Variable   ${walkin_order_len}

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['WALK_IN_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${walkin_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['WALK_IN_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-5

    [Documentation]   take order(pick up) for a provider by 10 consumers for the same date and check account level analytics for WALK_IN_ORDER matrix.
    
    ${order_ids4}=  Create List
    Set Suite Variable   ${order_ids4}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

        ${DAY1}=  add_date   12
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Test Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME22}.ynwtest@netvarth.com
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Test Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_A}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids4}  ${orderid${a}}

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=   Get Order by uid   ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${order_ids4}
    
    ${walkin_order_len1}=   Evaluate   $walkin_order_len + len($order_ids4) 
    Set Suite Variable   ${walkin_order_len1}

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['WALK_IN_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${walkin_order_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['WALK_IN_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-6

    [Documentation]   take order(home delivery) for a provider by 10 consumers for the same date and check account level analytics for PHONE_IN_ORDER matrix.
    
    ${order_ids5}=  Create List
    Set Suite Variable   ${order_ids5}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Test Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Test Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Test Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_A}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  
        ...   ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        ...   orderMode=${order_mode[2]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids5}  ${orderid${a}}

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=   Get Order by uid   ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${order_ids5}
    
    ${phonein_order_len1}=   Evaluate   len($order_ids5) 
    Set Suite Variable   ${phonein_order_len1}

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PHONE_IN_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${phonein_order_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PHONE_IN_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-7

    [Documentation]   take order(pick up) for a provider by 10 consumers for the same date and check account level analytics for PHONE_IN_ORDER matrix.

    ${order_ids6}=  Create List
    Set Suite Variable   ${order_ids6}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}

        ${DAY1}=  add_date   12
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Test Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Test Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_A}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids6}  ${orderid${a}}

    END   

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=   Get Order by uid   ${orderid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${order_ids6}
    
    ${phonein_order_len2}=   Evaluate   len($order_ids6) 
    Set Suite Variable   ${phonein_order_len2}

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PHONE_IN_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${phonein_order_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PHONE_IN_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    
    # ${resp}=  Get Account Level Analytics  metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AccountLevelAnalyticsforOrder-8

    [Documentation]   take order for a provider by consumers for the same date and check account level analytics for TOTAL_ORDER and BRAND_NEW_ORDERS matrix.

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
    
    ${total_order_len}=   Evaluate   $online_order_len2 + $walkin_order_len1 + $phonein_order_len1 + $phonein_order_len2
    Set Suite Variable   ${total_order_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['TOTAL_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${total_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['TOTAL_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['BRAND_NEW_ORDERS']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['BRAND_NEW_ORDERS']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-9

    [Documentation]   take order for a provider by consumers for the same date and check account level analytics for ORDERS_FOR_BILLING matrix.

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}
    
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${lic_bill_order_len}=   Evaluate   $online_order_len2 + $walkin_order_len1 + $phonein_order_len1 + $phonein_order_len2 - $no_of_cust
    Set Suite Variable   ${lic_bill_order_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ORDERS_FOR_BILLING']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${lic_bill_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ORDERS_FOR_BILLING']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-10

    [Documentation]   take order for a provider by consumers for the same date and check account level analytics for WEB_ORDER matrix.

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
    
    ${web_order_len}=   Evaluate   $online_order_len2 + $walkin_order_len1 + $phonein_order_len1 + $phonein_order_len2
    Set Suite Variable   ${web_order_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['WEB_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${web_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['WEB_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-11

    [Documentation]   take order for a provider by consumers for the same date and check account level analytics for TOTAL_ON_ORDER matrix.
    
    ${order_ids}=  Create List
    Set Test Variable   ${order_ids}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${DAY1}=  get_date  
   
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
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH}.ynwtest@netvarth.com
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Test Variable  ${address}

        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.ynwtest@netvarth.com

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${pid}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME${a}}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}
      
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

    Log Many   ${order_ids}  

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
    
    ${total_on_order_len}=   Evaluate   len($order_ids)
    Set Suite Variable   ${total_on_order_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['TOTAL_ON_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${total_on_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['TOTAL_ON_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-12

    [Documentation]    take order for a provider by consumers for the same date and check account level analytics for RECEIVED_ORDER matrix.

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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['RECEIVED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${total_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['RECEIVED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
   
JD-TC-AccountLevelAnalyticsforOrder-13

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for ACKNOWLEDGED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[0]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[1]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

  
JD-TC-AccountLevelAnalyticsforOrder-14

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for CONFIRMED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[1]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[2]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['CONFIRMED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['CONFIRMED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-15

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for PREPARING_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[2]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[3]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PREPARING_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PREPARING_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    FOR   ${a}  IN RANGE   ${count2}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids1[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[0]}

        ${resp}=  Change Order Status   ${order_ids1[${a}]}   ${StatusList[3]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${preparing_order_status_len}=   Evaluate  len($order_ids) + len($order_ids1) - 3
    Set Suite Variable   ${preparing_order_status_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PREPARING_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${preparing_order_status_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PREPARING_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-16

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for PACKING_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[3]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[4]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PACKING_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PACKING_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

   

JD-TC-AccountLevelAnalyticsforOrder-17

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for READY_FOR_SHIPMENT_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[4]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[7]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalyticsforOrder-18

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for READY_FOR_DELIVERY_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[7]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[8]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['READY_FOR_DELIVERY_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['READY_FOR_DELIVERY_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-19

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for COMPLETED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[8]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[9]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['COMPLETED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['COMPLETED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-20

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for IN_TRANSIT_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[9]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[10]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-21

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for SHIPPED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[10]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[11]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['SHIPPED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['SHIPPED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-22

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for PAYMENT_REQUIRED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[11]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[5]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-23

    [Documentation]   take order for a provider(home delivery) by consumers for the same date and check account level analytics for CANCEL_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[5]}

        ${resp}=  Change Order Status   ${order_ids[${a}]}   ${StatusList[12]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['CANCEL_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['CANCEL_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['BRAND_NEW_ORDERS']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

 
JD-TC-AccountLevelAnalyticsforOrder-24

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for ACKNOWLEDGED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[0]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[1]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
 
JD-TC-AccountLevelAnalyticsforOrder-25

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for CONFIRMED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[1]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[2]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['CONFIRMED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['CONFIRMED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
     
JD-TC-AccountLevelAnalyticsforOrder-26

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for PREPARING_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[2]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[3]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PREPARING_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${preparing_order_status_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PREPARING_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
   
JD-TC-AccountLevelAnalyticsforOrder-27

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for PACKING_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[3]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[4]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PACKING_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PACKING_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-28

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for READY_FOR_PICKUP_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[4]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[6]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['READY_FOR_PICKUP_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['READY_FOR_PICKUP_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-29

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for READY_FOR_SHIPMENT_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[6]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[7]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-30

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for COMPLETED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[7]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[9]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['COMPLETED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['COMPLETED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-31

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for IN_TRANSIT_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[9]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[10]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-32

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for SHIPPED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[10]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[11]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['SHIPPED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['SHIPPED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-33

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for PAYMENT_REQUIRED_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[11]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[5]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


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

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${online_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalyticsforOrder-34

    [Documentation]   take order for a provider(pickup) by consumers for the same date and check account level analytics for CANCEL_ORDER matrix.
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
            
        ${resp}=   Get Order by uid   ${order_ids2[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['orderStatus']}         ${StatusList[5]}

        ${resp}=  Change Order Status   ${order_ids2[${a}]}   ${StatusList[12]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids2[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Provider Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  01s
    # sleep  07m
    
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancel_order_len}=   Evaluate  $online_order_len + $online_order_len
    Set Suite Variable   ${cancel_order_len}

    ${resp}=  Get Account Level Analytics  metricId=${orderAnalyticsMetrics['CANCEL_ORDER']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${cancel_order_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${orderAnalyticsMetrics['CANCEL_ORDER']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
