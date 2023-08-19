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

${catalogName1}   CatalogName1
${catalogName2}   CatalogName2
${catalogName3}   CatalogName3
${catalogName4}   CatalogName4
${catalogName22}   CatalogName22
${catalogName33}   CatalogName33



*** Test Cases ***

JD-TC-Change_Catalog_Status-1

    [Documentation]  Create order catalog and change catalog status after that
    clear_Item  ${PUSERNAME38}
    
    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
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
    ${itemCode1}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode1}  

    ${itemCode2}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode2}   
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}
    
    ${itemName1}=   FakerLibrary.word 
    Set Suite Variable  ${itemName1}

    ${itemName2}=   FakerLibrary.name 
    Set Suite Variable  ${itemName2}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Pid1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Pid2}  ${resp.json()}



    ${resp}=   Get Item By Id  ${Pid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   


    ${resp}=   Get Item By Id  ${Pid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    
    ${startDate}=  get_date
    Set Suite Variable  ${startDate}
    ${endDate}=  add_date  10      
    Set Suite Variable  ${endDate}

    # ${noOfOccurance}=  Random Int  min=0   max=10
    # Set Suite Variable  ${noOfOccurance}

    Set Suite Variable  ${noOfOccurance}   0

    ${sTime1}=  add_time  0  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   0  30
    Set Suite Variable   ${eTime1}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title} 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text}

    ${minQuantity}=  Random Int  min=1   max=30
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
    ${StatusOfOrder}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusOfOrder}
    # -----------------------
    ${List_Item1}=  Create Dictionary  itemId=${Pid1}
    ${List_Item2}=  Create Dictionary  itemId=${Pid2}
    ${catalogItem1}=  Create Dictionary  item=${List_Item1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${List_Item2}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    # -----------------------
    
    # ${orderType}=  Random Element    ${OrderType}
    # ${catalogStatus}=  Random Element    ${catalogStatus}
    # ${paymentType}=  Random Element    ${AdvancedPaymentType}

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${StatusOfCatalog}   ${catalogStatus[1]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}

    ${far}=  Random Int  min=1   max=1000
    Set Suite Variable  ${far}

    ${soon}=  Random Int  min=1   max=1000
    Set Suite Variable  ${soon}

    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusOfOrder}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${StatusOfCatalog}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Change Catalog Status    ${CatalogId1}    ACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Change_Catalog_Status-2

    [Documentation]  Create order catalog for Store_pickup using mandatory fields and change catalog status after that

    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName22}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName22}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName22}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusOfOrder}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId22}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId22}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId22}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Catalog    ${CatalogId22}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Change_Catalog_Status-3
    [Documentation]  Create order catalog for Home_delivery using mandatory fields and change catalog status after that
    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName33}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName33}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName33}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusOfOrder}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId33}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId33}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId33}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Catalog    ${CatalogId33}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Change_Catalog_Status-UH1

    [Documentation]  Again Change Catalog Status as INACTIVE
    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Catalog Status    ${CatalogId1}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ALREADY_INACTIVE}=  Format String   ${CATALOG_STATUSES}    InActive

    ${resp}=  Change Catalog Status    ${CatalogId1}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ALREADY_INACTIVE}"

    # ${resp}=  Change Catalog Status    ${CatalogId2}    INACTIVE
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Change Catalog Status    ${CatalogId2}    INACTIVE
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${ALREADY_INACTIVE}"



JD-TC-Change_Catalog_Status-UH2

    [Documentation]  Again Change Catalog Status as ACTIVE
    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Catalog Status    ${CatalogId1}    ACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ALREADY_ACTIVE}=  Format String   ${CATALOG_STATUSES}    Active
    ${resp}=  Change Catalog Status    ${CatalogId1}    ACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ALREADY_ACTIVE}"

    # ${resp}=  Change Catalog Status    ${CatalogId2}    ACTIVE
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Change Catalog Status    ${CatalogId2}    ACTIVE
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${ALREADY_ACTIVE}"


JD-TC-Change_Catalog_Status-UH3

    [Documentation]  Change Catalog Status using invalid catalog_id
    ${resp}=  ProviderLogin  ${PUSERNAME38}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 

    ${resp}=  Change Catalog Status    ${Invalid_id}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_CATALOG_FOUND}"



JD-TC-Change_Catalog_Status-UH4
    [Documentation]   Change Catalog Status Without login

    ${resp}=  Change Catalog Status    ${CatalogId22}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Change_Catalog_Status-UH5
    [Documentation]   Login as consumer and Change Catalog Status
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId33}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Change_Catalog_Status-UH6
    [Documentation]   A provider try to change another providers catalog status
    clear_Item  ${PUSERNAME200}
    ${resp}=  ProviderLogin  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId22}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-Change_Catalog_Status-4
    [Documentation]    Place an order By Consumer for Home Delivery and try to change catalog status as INACTIVE
    clear_queue    ${PUSERNAME112}
    clear_service  ${PUSERNAME112}
    clear_customer   ${PUSERNAME112}
    clear_Item   ${PUSERNAME112}
    
    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    ${accId}=  get_acc_id  ${PUSERNAME112}
    Set Suite Variable  ${accId}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME112}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1} 
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence   
    ${itemCode1}=   FakerLibrary.word 
    ${promoLabel1}=   FakerLibrary.word 
    
    ${itemName1}=   FakerLibrary.firstname 
    Set Test Variable  ${itemName1}

    ${itemCode1}=   FakerLibrary.lastname 
    Set Test Variable  ${itemCode1}  
    
    ${displayName1}=   FakerLibrary.name 
    Set Test Variable  ${displayName1}  

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  add_date   11
    ${endDate1}=  add_date  15 

    ${noOfOccurance}=  Random Int  min=0   max=0
    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30 
    Set Suite Variable  ${SCHEDULE_sTime1}   ${sTime1} 
    Set Suite Variable  ${SCHEDULE_eTime1}   ${eTime1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${deliveryCharge}=  Random Int  min=1   max=100
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    ${minQuantity2}=  Random Int  min=1   max=30
    Set Suite Variable  ${minQuantity2}
    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable  ${maxQuantity2}
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

    ${Status_OF_Order2}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Status_OF_Order2}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity2}   maxQuantity=${maxQuantity2}  
    ${Item_list1}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${StatusOfCatalog}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    ${advanceAmount}=  Random Int  min=1   max=1000
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=1   max=1
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Test Variable  ${catalogName1}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order2}   ${Item_list1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${StatusOfCatalog}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId11}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  add_date   12
    # ${address}=  get_address
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
    # ${sTime1}=  add_time  0  15
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId}    ${self}    ${CatalogId11}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId11}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


*** comment ***
JD-TC-Change_Catalog_Status-5
    [Documentation]    Change order status as COMPLETED and try to change catalog status as INACTIVE
    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Catalog Status    ${CatalogId11}    ACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Change Order Status   ${orderid1}   ${Status_OF_Order2[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Status Changes by uid    ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Catalog Status    ${CatalogId11}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Change Catalog Status    ${CatalogId11}    ACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Change_Catalog_Status-6
    [Documentation]    Change order status as CANCELLED and try to change catalog status as INACTIVE
    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  add_date   12
    # ${address}=  get_address
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
    
    # ${sTime1}=  add_time  0  15
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity2}   max=${maxQuantity2}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.${test_mail}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}   ${accId}    ${self}    ${CatalogId11}   ${bool[1]}    ${address}    ${SCHEDULE_sTime1}    ${SCHEDULE_eTime1}   ${DAY1}    ${CUSERNAME10}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Change Order Status   ${orderid2}   ${Status_OF_Order2[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Order Status Changes by uid    ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Catalog Status    ${CatalogId11}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


