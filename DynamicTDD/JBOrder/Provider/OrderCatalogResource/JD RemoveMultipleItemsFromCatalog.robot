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


*** Test Cases ***
JD-TC-Remove_Multiple_Items_From_Catalog-1
    [Documentation]  Create order catalog and Remove Items From Catalog after that
    clear_Item  ${PUSERNAME56}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
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

    ${itemName2}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemName2}
    
    ${itemCode1}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode1}

    ${itemCode2}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode2}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid2}  ${resp.json()}

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

    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate}
    Set Suite Variable  ${noOfOccurance}   0
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
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
    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${orderStatuses}
    # -----------------------
    
    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${item2_Id}=  Create Dictionary  itemId=${Pid2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem2}
    Set Suite Variable  ${catalogItem}

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[1]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}
    ${far}=  Random Int  min=1   max=10
    Set Suite Variable  ${far}
    # ${soon}=  Random Int  min=1   max=10
    Set Suite Variable  ${soon}    0
    Set Suite Variable  ${minNumberItem}   1
    Set Suite Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId1}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    

JD-TC-Remove_Multiple_Items_From_Catalog-2
    [Documentation]  Create order catalog using mandatory fields and Remove Items From Catalog after that
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName2}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId2}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Remove_Multiple_Items_From_Catalog-3

    [Documentation]  Remove multiple items from catalog

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${itemName3}=   FakerLibrary.lastname 
    Set Suite Variable  ${itemName3}

    ${itemName4}=   FakerLibrary.name 
    Set Suite Variable  ${itemName4}

    ${itemCode3}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode3}

    ${itemCode4}=   FakerLibrary.lastname 
    Set Suite Variable  ${itemCode4}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid3}  ${resp.json()}
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid4}  ${resp.json()}
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

    ${resp}=  Add Items To Catalog    ${CatalogId2}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId1}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId2}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Remove_Multiple_Items_From_Catalog-4
    [Documentation]  Remove items form catalog, when Catalog status is INACTIVE
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName3}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName3}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}    pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Change Catalog Status    ${CatalogId3}    INACTIVE
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId3}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Remove_Multiple_Items_From_Catalog-UH1
    [Documentation]  Remove items from catalog using invalid catalog_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 

    ${resp}=  Remove Multiple Items From Catalog    ${Invalid_id}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_CATALOG_FOUND}"


JD-TC-Remove_Multiple_Items_From_Catalog-UH2
    [Documentation]  Remove items from catalog using invalid item_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId2}    ${Invalid_id}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_ITEM_NOT_FOUND}"



JD-TC-Remove_Multiple_Items_From_Catalog-UH3
    [Documentation]   Remove items from catalog Without login

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId1}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Remove_Multiple_Items_From_Catalog-UH4
    [Documentation]   Login as consumer and Remove items from catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId1}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Remove_Multiple_Items_From_Catalog-UH5
    [Documentation]   A provider try to Remove items from catalog of another provider
    clear_Item  ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Multiple Items From Catalog    ${CatalogId1}    ${Pid2}   ${Pid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"




