*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}    0
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf


*** Test Cases ***

JD-TC-Order_MassCommunication-1
    [Documentation]    Place an order By Provider for pickup (Both ShoppingCart and ShoppingList).
    
    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${c15_Uid}     ${resp.json()['id']}
    Set Suite Variable  ${c15_UName}   ${resp.json()['userName']}
    clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${PUSERNAME127}
    clear_queue    ${PUSERNAME127}
    clear_service  ${PUSERNAME127}
    clear_customer   ${PUSERNAME127}
    clear_Item   ${PUSERNAME127}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid1}  ${decrypted_data['id']}
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME127}
    Set Suite Variable  ${accId3} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${email_id}  ${firstname}${PUSERNAME127}.${test_mail}

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings


    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
   
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${displayName3}=   FakerLibrary.name 
    Set Suite Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Suite Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Suite Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Suite Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Suite Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Suite Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id4}  ${resp.json()}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    Set Suite Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  1  05  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  15   
    Set Suite Variable    ${eTime2}


    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    Set Suite Variable    ${deliveryCharge}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Suite Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Suite Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Suite Variable   ${maxQuantity3}


    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Suite Variable  ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Suite Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Suite Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Suite Variable  ${homeDelivery}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Suite Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Suite Variable  ${postInfo}
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Suite Variable  ${StatusList1} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Suite Variable  ${catalogItem}
    Set Suite Variable  ${orderType1}       ${OrderTypes[0]}
    Set Suite Variable  ${orderType2}       ${OrderTypes[1]}
    Set Suite Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Suite Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Suite Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Suite Variable  ${soon}
    Set Suite Variable  ${minNumberItem}   1

    Set Suite Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Suite Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME29}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid18}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Suite Variable  ${DAY1}
    ${DATE12}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE12}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME29}.${test_mail}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid11}  ${orderid[0]}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Suite Variable  ${item_quantity1}

    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${orderNote}

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid12}  ${orderid[0]}


    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no11}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no12}  ${resp.json()['orderNumber']}

    # --------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=    Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg1}=  FakerLibrary.text
    ${resp}=  Order Mass Communication    ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg1}    ${fileswithcaption}   ${orderid11}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c15_UName}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg1}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []

     Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid12}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []

     Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    ${resp}=  Consumer Login  ${CUSERNAME29}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
     Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid12}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}



JD-TC-Order_MassCommunication-2
    [Documentation]    Place an order By Provider for Home Delivery (Both ShoppingCart and ShoppingList).           

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${PUSERNAME127}

    ${DAY10}=  db.add_timezone_date  ${tz}   10
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
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for HomeDelivery    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY10}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid21}  ${orderid[0]}


    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY10}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid22}  ${orderid[0]}


    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid21}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no21}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid22}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no22}  ${resp.json()['orderNumber']}

    # --------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg2}=  FakerLibrary.text
    ${resp}=  Order Mass Communication     ${cookie}   ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg2}    ${fileswithcaption}   ${orderid21}  ${orderid22}
    # ${resp}=  Order Mass Communication  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg2}  ${orderid21}  ${orderid22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c15_UName}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg2}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid21}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []

    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    ${resp}=  Consumer Login  ${CUSERNAME29}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid21}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []

    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}




JD-TC-Order_MassCommunication-3
    [Documentation]    Place an order By Consumer for Home Delivery.
    clear_Consumermsg  ${CUSERNAME20}
    clear_Providermsg  ${PUSERNAME127}
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c20_Uid}     ${resp.json()['id']}
    Set Suite Variable  ${c20_UName}   ${resp.json()['userName']}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${DATE12}=  Convert Date  ${DAY12}  result_format=%a, %d %b %Y
    Set Suite Variable  ${DATE12}
    # ${address}=  get_address
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${caption}=  FakerLibrary.Sentence   nb_words=4
    ${Coupon_list}=  Create List

    ${resp}=   Upload ShoppingList Image for HomeDelivery    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${address}   ${DAY12}    ${sTime1}    ${eTime1}    ${CUSERNAME20}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid31}  ${orderid[0]}

    ${EMPTY_List}=  Create List
    Set Suite Variable  ${EMPTY_List}

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId3}    ${self}    ${CatalogId2}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY12}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}   ${Coupon_list}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid32}  ${orderid[0]}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid31}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no31}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid32}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no32}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid  ${orderid31}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid  ${orderid32}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg3}=  FakerLibrary.text
    ${resp}=  Order Mass Communication  ${cookie}   ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg3}    ${fileswithcaption}   ${orderid31}  ${orderid32}
    # ${resp}=  Order Mass Communication  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg3}  ${orderid31}  ${orderid32}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c20_UName}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg3}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid31}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid32}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    ${resp}=  Consumer Login  ${CUSERNAME20}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid31}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c20_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid32}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}




JD-TC-Order_MassCommunication-4
    [Documentation]    Place an order By consumer for pickup.
    clear_Consumermsg  ${CUSERNAME20}
    clear_Providermsg  ${PUSERNAME127}
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY12}=  db.add_timezone_date  ${tz}  12  
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
    ${caption}=  FakerLibrary.Sentence   nb_words=4

    ${resp}=   Upload ShoppingList Image for Pickup    ${cookie}   ${accId3}   ${caption}   ${self}    ${CatalogId1}   ${bool[1]}   ${DAY12}    ${sTime1}    ${eTime1}    ${CUSERNAME20}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid41}  ${orderid[0]}

    ${resp}=   Create Order For Pickup  ${cookie}  ${accId3}    ${self}    ${CatalogId2}    ${bool[1]}    ${sTime1}    ${eTime1}   ${DAY12}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid42}  ${orderid[0]}


    ${resp}=   Get Order By Id  ${accId3}  ${orderid41}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no41}  ${resp.json()['orderNumber']}
    
    ${resp}=   Get Order By Id  ${accId3}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${order_no42}  ${resp.json()['orderNumber']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get Order by uid    ${orderid41} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid    ${orderid42} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg4}=  FakerLibrary.text
    ${resp}=  Order Mass Communication     ${cookie}   ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg4}    ${fileswithcaption}   ${orderid41}  ${orderid42}

    # ${resp}=  Order Mass Communication  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg4}  ${orderid41}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c20_UName}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg4}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid42}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}



    ${resp}=  Consumer Login  ${CUSERNAME20}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c20_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []

    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid42}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}




JD-TC-Order_MassCommunication-5
    [Documentation]    Order Mass Communication.
    clear_Consumermsg  ${CUSERNAME20}
    clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${PUSERNAME127}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
 

    ${msg5}=  FakerLibrary.text
    ${resp}=  Order Mass Communication    ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg5}    ${fileswithcaption}   ${orderid11}  ${orderid21}  ${orderid31}  ${orderid41}  ${orderid12}  ${orderid22}  ${orderid32}  ${orderid42}

    # ${resp}=  Order Mass Communication  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg5}  ${orderid11}  ${orderid21}  ${orderid31}  ${orderid41}  ${orderid12}  ${orderid22}  ${orderid32}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg1}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg1}=  Replace String  ${Order_Msg1}  [consumer]   ${c15_UName}
    ${Order_Msg1}=  Replace String  ${Order_Msg1}  [message]   ${msg5}

    ${Order_Msg2}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg2}=  Replace String  ${Order_Msg2}  [consumer]   ${c20_UName}
    ${Order_Msg2}=  Replace String  ${Order_Msg2}  [message]   ${msg5}

    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid21}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${orderid31}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}


    Should Be Equal As Strings  ${resp.json()[4]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[4]['waitlistId']}         ${orderid12}
    Should Be Equal As Strings  ${resp.json()[4]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[4]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[4]['attachements']}       []
    Should Contain 	${resp.json()[4]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[4]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[4]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}
    
    Should Be Equal As Strings  ${resp.json()[5]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[5]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[5]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[5]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[5]['attachements']}       []
    Should Contain 	${resp.json()[5]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[5]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[5]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[6]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[6]['waitlistId']}         ${orderid32}
    Should Be Equal As Strings  ${resp.json()[6]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[6]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[6]['attachements']}       []
    Should Contain 	${resp.json()[6]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[6]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[6]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[7]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[7]['waitlistId']}         ${orderid42}
    Should Be Equal As Strings  ${resp.json()[7]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[7]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[7]['attachements']}       []
    Should Contain 	${resp.json()[7]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[7]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[7]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    


    ${resp}=  Consumer Login  ${CUSERNAME29}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid11}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c15_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid21}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${orderid12}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${orderid22}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${Order_Msg1}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${c15_Uid}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}



    ${resp}=  Consumer Login  ${CUSERNAME20}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${orderid31}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${c20_Uid} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${orderid41}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []
    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${orderid32}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${orderid42}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${Order_Msg2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${c20_Uid}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}



JD-TC-Order_MassCommunication-UH1
    [Documentation]  Send appointment comunication message to consumer without login
    
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg5}=  FakerLibrary.text
    ${resp}=  Order Mass Communication     ${EMPTY}   ${bool[1]}  ${bool[1]}  ${bool[1]}    ${bool[1]}    ${msg5}    ${fileswithcaption}    ${orderid11}  ${orderid21}  ${orderid31}  ${orderid41}  ${orderid12}  ${orderid22}  ${orderid32}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}" 


JD-TC-Order_MassCommunication-UH2
    [Documentation]  Send appointment comunication message to consumer by another provider
    clear_Consumermsg  ${CUSERNAME20}
    clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${PUSERNAME127}
    clear_Providermsg  ${PUSERNAME183}
    ${resp}=  Encrypted Provider Login   ${PUSERNAME183}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME183}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg5}=  FakerLibrary.text
    ${resp}=  Order Mass Communication    ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}    ${bool[1]}  ${msg5}   ${fileswithcaption}    ${orderid11}  ${orderid21}  ${orderid31}  ${orderid41}  ${orderid12}  ${orderid22}  ${orderid32}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
    # ${EMPTY_List}=  Create List
    # ${resp}=  Get provider communications
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()}    ${EMPTY_List}

    # ${resp}=  Consumer Login  ${CUSERNAME29}   ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Consumer Communications
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings    ${resp.json()}    ${EMPTY_List}


JD-TC-Order_MassCommunication-UH3
    [Documentation]  Send order comunication message using invalid Order id
    clear_Providermsg  ${PUSERNAME127}
    ${resp}=  Encrypted Provider Login   ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=   Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg5}=  FakerLibrary.text
    ${resp}=  Order Mass Communication      ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}    ${msg5}    ${fileswithcaption}    000000abcd
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}    ${EMPTY_List}
    


JD-TC-Order_MassCommunication-UH4
    [Documentation]  Send appointment comunication message by consumer login

    ${resp}=  Consumer Login   ${CUSERNAME29}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.conLogin     ${CUSERNAME29}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=    Create List   ${filecap_dict1}   ${filecap_dict2}   ${filecap_dict3}
    ${msg5}=  FakerLibrary.text
    ${resp}=   Order Mass Communication      ${cookie}   ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}    ${msg5}     ${fileswithcaption}     ${orderid11}  ${orderid21}  ${orderid31}  ${orderid41}  ${orderid12}  ${orderid22}  ${orderid32}  ${orderid42}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"


