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

JD-TC-Update_Catalog_For_ShoppingList-1

    [Documentation]  Provider Create order catalog For SHOPPINGLIST
    clear_Item  ${PUSERNAME62}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
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

    ${minQuantity}=  Random Int  min=1   max=3
    Set Suite Variable  ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable  ${maxQuantity}

    ${catalogName}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName} 

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
    ${Statuses_list1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Statuses_list1}
    # -----------------------


    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}

    ${far}=  Random Int  min=1   max=1000
    Set Suite Variable  ${far}

    ${soon}=  Random Int  min=1   max=1000
    Set Suite Variable  ${soon}

    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5


    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    
    ${resp}=  Create Catalog For ShoppingList   ${catalogName}  ${EMPTY}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${Statuses_list1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${startDate2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${startDate2}
    ${endDate2}=  db.add_timezone_date  ${tz}  45      
    Set Suite Variable  ${endDate2}

   
    ${sTime2}=  add_timezone_time  ${tz}  0  10  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${eTime2}

    ${list2}=  Create List  1  2  3  4  5  6  
    Set Suite Variable  ${list2}

    ${deliveryCharge2}=  Random Int  min=50   max=1000
    Set Suite Variable  ${deliveryCharge2}

    ${Title2}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${Title2} 
    ${Text2}=  FakerLibrary.Sentence   nb_words=4
    Set Suite Variable  ${Text2}

    ${minQuantity2}=  Random Int  min=1   max=3
    Set Suite Variable  ${minQuantity2}

    ${maxQuantity2}=  Random Int  min=${minQuantity2}   max=50
    Set Suite Variable  ${maxQuantity2}

    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2} 

    ${catalogDesc2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc2} 

    ${cancelationPolicy2}=  FakerLibrary.Sentence   nb_words=6
    Set Suite Variable  ${cancelationPolicy2} 


    ${terminator2}=  Create Dictionary  endDate=${endDate2}  noOfOccurance=${noOfOccurance}
    ${timeSlot2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots2}=  Create List  ${timeSlot2}
    ${catalogSchedule2}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list2}  startDate=${startDate2}   terminator=${terminator2}   timeSlots=${timeSlots2}
    Set Suite Variable  ${catalogSchedule2}
    # -----------------------
    ${pickUp2}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp2}
    # -----------------------
    ${homeDelivery2}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule2}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=10   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge2}
    Set Suite Variable  ${homeDelivery2}
    # -----------------------
    ${preInfo2}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title2}   preInfoText=${Text2}   
    Set Suite Variable  ${preInfo2}
    # -----------------------
    ${postInfo2}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title2}   postInfoText=${Text2}   
    Set Suite Variable  ${postInfo2}
    # -----------------------
    ${Statuses_list2}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Statuses_list2}
    # -----------------------
  
    
    ${advanceAmount2}=  Random Int  min=15   max=1000
    Set Suite Variable  ${advanceAmount2}

    
    ${resp}=  Update Catalog For ShoppingList   ${CatalogId3}   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Create Catalog For ShoppingList   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Create Catalog For ShoppingList   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Create Catalog For ShoppingList   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Update_Catalog_For_ShoppingList-UH1
    [Documentation]   Another provider also uses same details to Create catalog for shoppinglist
    clear_Item  ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

    ${resp}=  Update Catalog For ShoppingList   ${CatalogId3}   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-Update_Catalog_For_ShoppingList-UH2
    [Documentation]   Create catalog Without login

    ${resp}=  Update Catalog For ShoppingList   ${CatalogId3}   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Update_Catalog_For_ShoppingList-UH3
    [Documentation]   Login as consumer and Create catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Catalog For ShoppingList   ${CatalogId3}   ${catalogName2}  ${EMPTY}   ${catalogSchedule2}   ${orderType2}   ${paymentType}   ${Statuses_list2}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy2}   pickUp=${pickUp2}   homeDelivery=${homeDelivery2}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount2}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo2}   postInfo=${postInfo2}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


