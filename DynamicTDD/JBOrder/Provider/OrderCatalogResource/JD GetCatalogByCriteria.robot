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
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Get_Catalog_By_Criteria-1

    [Documentation]  Provider Create order catalog  and Get_Catalog_By_Criteria

    clear_Item  ${PUSERNAME10}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${account_id}  ${resp.json()['id']}
    # Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    
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

     
    ${itemName1}=   FakerLibrary.name
    Set Suite Variable  ${itemName1}   

    ${itemName2}=   FakerLibrary.name
    Set Suite Variable  ${itemName2}

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


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Pid2}  ${resp.json()}



    ${resp}=   Get Item By Id  ${Pid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Pid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate}

    # ${noOfOccurance}=  Random Int  min=0   max=10
    # Set Suite Variable  ${noOfOccurance}

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
    ${orderStatus_list}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${orderStatus_list}
    # -----------------------
    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    Set Suite Variable  ${catalogItem}
    # -----------------------
    

    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
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

    ${catalogName2}=   generate_firstname 
    Set Suite Variable  ${catalogName2}

    ${catalogName3}=   FakerLibrary.lastname 
    Set Suite Variable  ${catalogName3}

    ${catalogName4}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName4}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid1_Pid1}  ${resp.json()['catalogItem'][0]['catalogId']}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid2_Pid1}  ${resp.json()['catalogItem'][0]['catalogId']}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName3}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid3_Pid1}  ${resp.json()['catalogItem'][0]['catalogId']}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName4}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${orderStatus_list}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId4}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid4_Pid1}  ${resp.json()['catalogItem'][0]['catalogId']}

    ${resp}=  Get Catalog By Criteria    id-eq=${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Get Catalog By Criteria    catalogId-eq=${Cid1_Pid1}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Catalog By Criteria    catalogId-eq=${Cid2_Pid1}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Catalog By Criteria    catalogId-eq=${Cid3_Pid1}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Catalog By Criteria    catalogId-eq=${Cid4_Pid1}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName4}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get_Catalog_By_Criteria-UH1

    [Documentation]  Get_Items_From_Catalog using invalid id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=  Get Catalog By Criteria    id-eq=${Invalid_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_List} 

JD-TC-Get_Catalog_By_Criteria-UH2

    [Documentation]   Get_Items_From_Catalog Without login

    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Get_Catalog_By_Criteria-UH3

    [Documentation]   Login as consumer and Get_Items_From_Catalog

    ${resp}=   Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id}=    get_acc_id       ${PUSERNAME174}

    #............provider consumer creation..........

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME16}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    Set Test Variable  ${email}  ${fname}${CUSERNAME16}.${test_mail}

    ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${email}    ${CUSERNAME16}     ${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-Get_Catalog_By_Criteria-UH4

    [Documentation]   A provider try to Get_Items_From_Catalog of another provider

    clear_Item  ${PUSERNAME100}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria    catalogName-eq=${catalogName1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}   


