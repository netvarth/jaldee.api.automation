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

*** Test Cases ***

JD-TC-Remove_Single_Item_From_Catalog-1
    [Documentation]  Create order catalog and Remove Items From Catalog after that
    clear_Item  ${PUSERNAME89}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    
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
    ${Status_OF_Order1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${Status_OF_Order1}
    # -----------------------
    
    ${item1_Id}=  Create Dictionary  itemId=${Pid1}
    ${item2_Id}=  Create Dictionary  itemId=${Pid2}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    
    ${catalogItem}=  Create List   ${catalogItem1}   ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    # -----------------------

    Set Suite Variable  ${orderType}       ${OrderTypes[0]}
    Set Suite Variable  ${INACTIVEStatus}   ${catalogStatus[1]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Suite Variable  ${advanceAmount}

    
    
    # ${far}=  Random Int  min=1   max=10
    # ${soon}=  Random Int  min=1   max=10
    Set Suite Variable  ${far}     10
    Set Suite Variable  ${soon}    0

    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${INACTIVEStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    



JD-TC-Remove_Single_Item_From_Catalog-2

    [Documentation]  Create order catalog using mandatory fields and Remove Items From Catalog after that
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName5}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName5}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName5}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId55}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId55}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Single Item From Catalog    ${CatalogId55}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId55}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Remove_Single_Item_From_Catalog-3

    [Documentation]  Create order catalog using mandatory fields and Remove Items From Catalog after that
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName6}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName6}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName6}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId66}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId66}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Single Item From Catalog    ${CatalogId66}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId66}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Remove_Single_Item_From_Catalog-UH1

    [Documentation]  Try to remove already removed item from catalog
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Catalog    ${CatalogId66}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Single Item From Catalog    ${CatalogId66}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_ITEM_NOT_FOUND}"



JD-TC-Remove_Single_Item_From_Catalog-UH2
    [Documentation]  Remove items from catalog using invalid catalog_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 

    ${resp}=  Remove Single Item From Catalog    ${Invalid_id}    ${Pid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_CATALOG_FOUND}"


JD-TC-Remove_Single_Item_From_Catalog-UH3
    [Documentation]  Remove items from catalog using invalid item_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000   max=500000 

    ${resp}=  Remove Single Item From Catalog    ${CatalogId55}    ${Invalid_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CATALOG_ITEM_NOT_FOUND}"



JD-TC-Remove_Single_Item_From_Catalog-UH4
    [Documentation]   Remove items from catalog Without login

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${Pid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Remove_Single_Item_From_Catalog-UH5
    [Documentation]   Login as consumer and Remove items from catalog
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${Pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Remove_Single_Item_From_Catalog-UH6
    [Documentation]   A provider try to Remove items from catalog of another provider
    clear_Item  ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}   ${Pid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-Remove_Single_Item_From_Catalog-4
    [Documentation]  Remove all Items From Catalog
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${catalogName7}=   FakerLibrary.lastname 
    Set Suite Variable  ${catalogName7}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName7}  ${EMPTY}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   pickUp=${pickUp}   homeDelivery=${homeDelivery}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId77}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId77}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Remove Single Item From Catalog    ${CatalogId77}    ${Pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Single Item From Catalog    ${CatalogId77}    ${Pid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId77}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Remove_Single_Item_From_Catalog-UH7
    [Documentation]    Place an order By Consumer for Home Delivery. After that update catalog item quantity
    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    ${accId}=  get_acc_id  ${PUSERNAME89}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    Set Suite Variable  ${ACTIVEStatus}   ${catalogStatus[0]}

    ${catalogName8}=   FakerLibrary.firstname 
    Set Suite Variable  ${catalogName8}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName8}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${ACTIVEStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId3}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${Cid3_item_id1}  ${resp.json()['catalogItem'][0]['id']} 
    Set Suite Variable  ${Cid3_item_id2}  ${resp.json()['catalogItem'][1]['id']} 

    ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.add_timezone_date  ${tz}  1
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
    
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME38}.${test_mail}
    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME38}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId3}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME38}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${Pid1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    # clear_queue    ${PUSERNAME89}
    # clear_service  ${PUSERNAME89}
    # clear_customer   ${PUSERNAME89}
    # clear_Item   ${PUSERNAME89}
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME89}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    # ${accId}=  get_acc_id  ${PUSERNAME89}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # Set Test Variable  ${email_id}  ${firstname}${PUSERNAME89}.${test_mail}

    # ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Order Settings by account id
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    # ${displayName1}=   FakerLibrary.name 
    # ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    # ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    # ${price1}=  Random Int  min=50   max=300 
    # ${price1float}=  twodigitfloat  ${price1}
  
    # ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
    # ${promoPrice1}=  Random Int  min=10   max=${price1} 
    # ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    # ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    # ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    # ${note1}=  FakerLibrary.Sentence  
    # ${promoLabel1}=   FakerLibrary.word 

    # ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${item_id5}  ${resp.json()}

    # ${startDate}=  db.get_date_by_timezone  ${tz}
    # ${endDate}=  db.add_timezone_date  ${tz}  10        

    # ${startDate1}=  db.add_timezone_date  ${tz}  11  
    # ${endDate1}=  db.add_timezone_date  ${tz}  15   

    # ${noOfOccurance}=  Random Int  min=0   max=0
    # ${sTime2}=  add_timezone_time  ${tz}  0  15  
    # ${eTime2}=  add_timezone_time  ${tz}  3  30     
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${deliveryCharge}=  Random Int  min=1   max=100
    # ${Title}=  FakerLibrary.Sentence   nb_words=2 
    # ${Text}=  FakerLibrary.Sentence   nb_words=4
    # ${minQuantity}=  Random Int  min=1   max=30
    # ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    # ${catalogDesc}=   FakerLibrary.name 
    # ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    # ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    # ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    # ${timeSlots1}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    # ${timeSlots}=  Create List  ${timeSlots1}
    # ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    # ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    # ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    # ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    # ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    # ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    # ${Status_OF_Order2}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    # ${item5_Id}=  Create Dictionary  itemId=${item_id5}
    # ${catalogItem5}=  Create Dictionary  item=${item5_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${Item_list5}=  Create List   ${catalogItem5}
    
    # Set Test Variable  ${orderType}       ${OrderTypes[0]}
    # Set Test Variable  ${StatusOfCatalog}   ${catalogStatus[0]}
    # Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    # ${advanceAmount}=  Random Int  min=1   max=1000
    # ${far}=  Random Int  min=14  max=14
    # ${soon}=  Random Int  min=1   max=1
    # Set Test Variable  ${minNumberItem}   1
    # Set Test Variable  ${maxNumberItem}   5


    # ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${Status_OF_Order2}   ${Item_list5}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${StatusOfCatalog}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${CatalogId11}   ${resp.json()}

    # ${resp}=  Get Order Catalog    ${CatalogId11}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${DAY1}=  db.add_timezone_date  ${tz}  12  
    # ${address}=  get_address
    # # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # # ${delta}=  FakerLibrary.Random Int  min=10  max=90
    # # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    # ${firstname}=  FakerLibrary.first_name
    # Set Test Variable  ${email}  ${firstname}${CUSERNAME38}.${test_mail}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME38}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200

    # ${resp}=   Create Order For HomeDelivery    ${cookie}  ${accId}    ${self}    ${CatalogId11}   ${bool[1]}    ${address}    ${sTime2}    ${eTime2}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id5}    ${item_quantity1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${orderid1}  ${orderid[0]}

    # ${resp}=   Get Order By Id  ${accId}  ${orderid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200



