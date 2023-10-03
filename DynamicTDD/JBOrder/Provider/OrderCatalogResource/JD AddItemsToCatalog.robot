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


*** Variables ***

${self}    0
${CUSERPH}      ${CUSERNAME}


*** Test Cases ***

JD-TC-Add_Items_To_Catalog-1

    [Documentation]  Create order catalog and Add Items To Catalog after that

    clear_Item  ${PUSERNAME146}
    
    ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
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
    ${orderStatuses1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${orderStatuses1}
    # -----------------------
    
    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${item2_Id}=  Create Dictionary  itemId=${Pid2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    # -----------------------

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus1}   ${catalogStatus[0]}
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

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus1}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${itemName3}=   FakerLibrary.word 
    Set Suite Variable  ${itemName3}
    
    ${itemName4}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemName4}

    ${itemCode3}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode3}

    ${itemCode4}=   FakerLibrary.lastname 
    Set Suite Variable  ${itemCode4}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Pid3}  ${resp.json()}
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Pid4}  ${resp.json()}
    ${resp}=   Get Item By Id  ${Pid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName3}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode3}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    ${resp}=   Get Item By Id  ${Pid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName4}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode4}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${item3_Id}=  Create Dictionary  itemId=${Pid3}
    ${item4_Id}=  Create Dictionary  itemId=${Pid4}
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    
    ${Items_list}=  Create List   ${catalogItem3}   ${catalogItem4}
    Set Suite Variable  ${Items_list}

    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-Add_Items_To_Catalog-2
    [Documentation]  Create catalog using or Store_pickup and Add Items To Catalog after that

    ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName6}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName6}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName6}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}      pickUp=${pickUp}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId12}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId12}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Items To Catalog    ${CatalogId12}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId12}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-Add_Items_To_Catalog-3
    [Documentation]  Create catalog using or Home_delivery and Add Items To Catalog after that

    ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${catalogName7}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName7}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}      homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId22}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId22}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Items To Catalog    ${CatalogId22}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId22}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-Add_Items_To_Catalog-4

    [Documentation]  Item level coupon (coupon can be applied only if specific item is present)

    clear_queue    ${PUSERNAME147}
    clear_service  ${PUSERNAME147}
    clear_customer   ${PUSERNAME147}
    clear_Item   ${PUSERNAME147}

    ${resp}=  ProviderLogin  ${PUSERNAME147}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${accId}  ${resp.json()['id']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME147}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    clear_customer_groups  ${PUSERNAME147}
    
    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

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
    Set Test Variable  ${item_id1}  ${resp.json()}

     ${displayName2}=   FakerLibrary.name 
    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price2}

    ${itemName2}=   FakerLibrary.name  

    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}

    ${note2}=  FakerLibrary.Sentence   

    ${itemCode2}=   FakerLibrary.word 

    ${promoLabel2}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[1]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id2}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  add_date   11
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=10

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

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

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${item2_Id}=  Create Dictionary  itemId=${item_id2}   
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem21}=  Create List   ${catalogItem2}

       ${catalogName1}=   FakerLibrary.name  

    ${catalogDesc1}=   FakerLibrary.name 

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc1}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem21}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  add_time   0  45
    ${ST_DAY}=  get_date
    ${EN_DAY}=  add_date   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[1]}
    ${tc}=  FakerLibrary.sentence
    ${catalogues}=  Create List   ${CatalogId1}
    ${items}=   Create list   ${item_id1}
    ${groups}=   Create list   ${groupid}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  catalogues=${catalogues}   items=${items}   consumerGroups=${groups}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY1}=  add_date   12
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

    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${coupons}=  Create List  ${cupn_code}  

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${coupons}   ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${coupons}   ${item_id2}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid2}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME147}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

       ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




# JD-TC-Add_Items_To_Catalog-UH1

#     [Documentation]  Add Items To Catalog using invalid catalog_id
#     ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${Invalid_id}=  Random Int  min=100000   max=500000 

#     ${resp}=  Add Items To Catalog    ${Invalid_id}    ${Items_list}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_CATALOG_FOUND}"



JD-TC-Add_Items_To_Catalog-UH2

    [Documentation]   Add Items To Catalog Without login

    ${resp}=  Add Items To Catalog    ${CatalogId12}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Add_Items_To_Catalog-UH3

    [Documentation]   Login as consumer and Add Items To Catalog

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

 
    ${resp}=  Add Items To Catalog    ${CatalogId22}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-Add_Items_To_Catalog-UH4

    [Documentation]   A provider try to Add_Items_To_Catalog of another provider
    
    clear_Item  ${PUSERNAME147}
    ${resp}=  ProviderLogin  ${PUSERNAME147}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"




JD-TC-Add_Items_To_Catalog-UH5
    [Documentation]  Add inactive item to catalog

    ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${itemName5}=   FakerLibrary.word 
    Set Suite Variable  ${itemName5}

    ${itemCode5}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode5}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P2_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${P2_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName5}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode5}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${resp}=  Disable Item  ${P2_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${P2_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${item1_Id}=  Create Dictionary  itemId=${P2_id1}
    ${Item_list2}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${DisabledItem_List}=  Create List   ${Item_list2}

    ${UNABLE_TO_ADD_INVALID_ITEM}=  Format String   ${UNABLE_TO_ADD_INACTIVE_ITEMS}    Item ${displayName1} is inactive     inactive item

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${DisabledItem_List}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${UNABLE_TO_ADD_INVALID_ITEM}"



JD-TC-Add_Items_To_Catalog-UH6
    [Documentation]  Add item to catalog_for_SHOPPINGLIST

    ${resp}=  ProviderLogin  ${PUSERNAME146}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}

    ${catalogName4}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName4}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName4}  ${EMPTY}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${orderStatuses1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}      pickUp=${pickUp}   homeDelivery=${homeDelivery}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Add Items To Catalog    ${CatalogId4}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${UNABLE_TO_ADD_ITEMS}"


JD-TC-Add_Items_To_Catalog-UH7

    [Documentation]  Add inactive item to catalog

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    
    clear_Item  ${PUSERNAME112}

    ${itemdata}=   FakerLibrary.words    	nb=10
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid1}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName2}=   FakerLibrary.user name    
    ${price2}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   Set Variable     ${itemdata[2]} 
    ${itemCode2}=   Set Variable     ${itemdata[3]}
    ${resp}=  Create Sample Item   ${displayName2}   ${itemName2}  ${itemCode2}  ${price2}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid2}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName3}=   FakerLibrary.user name    
    ${price3}=  Evaluate    random.uniform(50.0,300) 
    ${itemName3}=   Set Variable     ${itemdata[4]} 
    ${itemCode3}=   Set Variable     ${itemdata[5]}
    ${resp}=  Create Sample Item   ${displayName3}   ${itemName3}  ${itemCode3}  ${price3}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName4}=   FakerLibrary.user name    
    ${price4}=  Evaluate    random.uniform(50.0,300) 
    ${itemName4}=   Set Variable     ${itemdata[6]} 
    ${itemCode4}=   Set Variable     ${itemdata[7]}
    ${resp}=  Create Sample Item   ${displayName4}   ${itemName4}  ${itemCode4}  ${price4}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  get_date
    ${endDate1}=  add_date  15  

    ${startDate2}=  add_date  5
    ${endDate2}=  add_date  25     
   
    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime3}=  add_time  0  15
    ${eTime3}=  add_time   1  00 
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
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
   
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${itemid1}
    ${item2_Id}=  Create Dictionary  itemId=${itemid2}
    ${item3_Id}=  Create Dictionary  itemId=${itemid3}
    ${item4_Id}=  Create Dictionary  itemId=${itemid4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3} 
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}   
    
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}  ${catalogItem3}  ${catalogItem4}
   
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    
    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.name  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Catalog By AccId    ${account_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Item  ${itemid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Catalog By AccId    ${account_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Item  ${itemid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Catalog By AccId    ${account_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


