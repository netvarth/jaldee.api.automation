*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions 
Force Tags        Reimburse Report
Library           Collections
Library           String
Library           json
Library           FakerLibrary  
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

@{emptylist} 
${self}         0
${CUSERPH}      ${CUSERNAME}

***Test Cases***


# JD-TC-orderreport-1
    
#     [Documentation]   take an online order(today, without prepayment) by a provider then 
#     ...   do the bill payment then generate order report and verify. 

#     ${resp}=  ProviderLogin  ${PUSERNAME90}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
#     Set Test Variable  ${pid1}  ${resp.json()['id']}

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id1}  ${resp.json()['id']}

#     ${highest_package}=  get_highest_license_pkg
#     Log  ${highest_package}
#     Set Suite variable  ${lic2}  ${highest_package[0]}

#     ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
#     Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
#     Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

#     clear_queue    ${PUSERNAME90}
#     clear_service  ${PUSERNAME90}
#     clear_Item   ${PUSERNAME90}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     Set Test Variable  ${email_id}  ${firstname}${PUSERNAME90}.ynwtest@netvarth.com

#     ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
  
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${displayName1}=   FakerLibrary.name 
#     ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
#     ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
#     ${price1}=  Random Int  min=50   max=300 
#     ${price1}=  Convert To Number  ${price1}  1
#     ${price1float}=  twodigitfloat  ${price1}
#     ${itemName1}=   FakerLibrary.name  
#     ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
#     ${promoPrice1}=  Random Int  min=10   max=${price1} 
#     ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
#     ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

#     ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
#     ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

#     ${note1}=  FakerLibrary.Sentence   

#     ${itemCode1}=   FakerLibrary.word 

#     ${promoLabel1}=   FakerLibrary.word 

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id1}  ${resp.json()}

#     ${startDate}=  get_date
#     ${endDate}=  add_date  10      

#     ${startDate1}=  get_date
#     ${endDate1}=  add_date  15      

#     ${noOfOccurance}=  Random Int  min=0   max=0

#     ${sTime1}=  add_time  0  15
#     ${eTime1}=  add_time   3  30 
#     ${list}=  Create List  1  2  3  4  5  6  7
  
#     ${deliveryCharge}=  Random Int  min=50   max=100
#     ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

#     ${Title}=  FakerLibrary.Sentence   nb_words=2 
#     ${Text}=  FakerLibrary.Sentence   nb_words=4

#     ${minQuantity}=  Random Int  min=1   max=30
#     ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
#     ${catalogName}=   FakerLibrary.name  
#     ${catalogDesc}=   FakerLibrary.name 
#     ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
#     ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

#     ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

#     ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
#     ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

#     ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
#     ${item}=  Create Dictionary  itemId=${item_id1}    
#     ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     ${catalogItem}=  Create List   ${catalogItem1}
  
#     Set Test Variable  ${orderType}       ${OrderTypes[0]}
#     Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
#     Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

#     ${advanceAmount}=  Random Int  min=1   max=1000
   
#     ${far}=  Random Int  min=14  max=14
   
#     ${soon}=  Random Int  min=0   max=0
   
#     Set Test Variable  ${minNumberItem}   1

#     Set Test Variable  ${maxNumberItem}   5

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${CatalogId1}   ${resp.json()}

#     ${resp}=  Get Order Catalog    ${CatalogId1}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
    
#     ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME12}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${DAY1}=  get_date
#     ${C_firstName}=   FakerLibrary.first_name 
#     ${C_lastName}=   FakerLibrary.name 
#     ${C_num1}    Random Int  min=123456   max=999999
#     ${CUSERPH1}=  Evaluate  ${CUSERNAME}+${C_num1}
#     Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH1}.ynwtest@netvarth.com
#     ${homeDeliveryAddress}=   FakerLibrary.name 
#     ${city}=  FakerLibrary.city
#     ${landMark}=  FakerLibrary.Sentence   nb_words=2 
#     ${address}=  Create Dictionary   phoneNumber=${CUSERNAME12}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
#     Set Test Variable  ${address}

#     ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
#     ${firstname}=  FakerLibrary.first_name
#     Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.ynwtest@netvarth.com
#     ${EMPTY_List}=  Create List

#     ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${orderid1}  ${orderid[0]}

#     ${resp}=   Get Order By Id    ${account_id1}   ${orderid1}   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  ProviderLogin  ${PUSERNAME90}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    
#     ${resp}=   Get Order by uid     ${orderid1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
#     Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
#     Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
#     Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
#     ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
#     ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
#     Set Suite Variable   ${totalPrice1}

#     ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
#     ${total}=  Convert To Number  ${total}  1

#     ${resp}=  Get Bill By UUId  ${orderid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

#     ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid1}  ${resp.json()['id']}
#     Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
#     ${resp}=  Make payment Consumer Mock  ${account_id1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
#     Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

#     ${resp}=  ConsumerLogout
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  ProviderLogin  ${PUSERNAME90}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Server Time
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${Date}    ${resp.json()}   
#     ${Date} =	Convert Date	${Date}	 result_format=%d/%m/%Y %I:%M %p

#     ${filter}=  Create Dictionary 
#     ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${token_id}   ${resp.json()}

#     ${resp}=  Get Report Status By Token Id  ${token_id}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['1']}   ${Date}                
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['2']}   ${cons_name1}              
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['3']}   ${countryCodes[0]}${CUSERNAME12}              
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['5']}   ${bookingType[3]}    ignore_case=True         
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['7']}   ${ordernumber}              
#     Variable Should Exist   ${resp.json()['reportContent']['data'][0]['10']}  ${total}
#     Variable Should Exist   ${resp.json()['reportContent']['data'][0]['15']}  ${total}

# JD-TC-orderreport-2
    
#     [Documentation]   take an walkin order(today, without prepayment) by a provider then 
#     ...   do the bill payment then generate order report and verify. 

#     ${resp}=  ProviderLogin  ${PUSERNAME91}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
#     Set Test Variable  ${pid1}  ${resp.json()['id']}

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id1}  ${resp.json()['id']}

#     ${highest_package}=  get_highest_license_pkg
#     Log  ${highest_package}
#     Set Suite variable  ${lic2}  ${highest_package[0]}

#     ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
#     Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
#     Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
#         ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END

#     ${resp}=   Get jaldeeIntegration Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

#     clear_queue    ${PUSERNAME91}
#     clear_service  ${PUSERNAME91}
#     clear_Item   ${PUSERNAME91}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     Set Test Variable  ${email_id}  ${firstname}${PUSERNAME91}.ynwtest@netvarth.com

#     ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
  
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${displayName1}=   FakerLibrary.name 
#     ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
#     ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
#     ${price1}=  Random Int  min=50   max=300 
#     ${price1}=  Convert To Number  ${price1}  1
#     ${price1float}=  twodigitfloat  ${price1}
#     ${itemName1}=   FakerLibrary.name  
#     ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
#     ${promoPrice1}=  Random Int  min=10   max=${price1} 
#     ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
#     ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

#     ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
#     ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

#     ${note1}=  FakerLibrary.Sentence   

#     ${itemCode1}=   FakerLibrary.word 

#     ${promoLabel1}=   FakerLibrary.word 

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id1}  ${resp.json()}

#     ${startDate}=  get_date
#     ${endDate}=  add_date  10      

#     ${startDate1}=  get_date
#     ${endDate1}=  add_date  15      

#     ${noOfOccurance}=  Random Int  min=0   max=0

#     ${sTime1}=  add_time  0  15
#     ${eTime1}=  add_time   3  30 
#     ${list}=  Create List  1  2  3  4  5  6  7
  
#     ${deliveryCharge}=  Random Int  min=50   max=100
#     ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

#     ${Title}=  FakerLibrary.Sentence   nb_words=2 
#     ${Text}=  FakerLibrary.Sentence   nb_words=4

#     ${minQuantity}=  Random Int  min=1   max=30
#     ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
#     ${catalogName}=   FakerLibrary.name  
#     ${catalogDesc}=   FakerLibrary.name 
#     ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
#     ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

#     ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

#     ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
#     ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

#     ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
#     ${item}=  Create Dictionary  itemId=${item_id1}    
#     ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     ${catalogItem}=  Create List   ${catalogItem1}
  
#     Set Test Variable  ${orderType}       ${OrderTypes[0]}
#     Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
#     Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

#     ${advanceAmount}=  Random Int  min=1   max=1000
   
#     ${far}=  Random Int  min=14  max=14
   
#     ${soon}=  Random Int  min=0   max=0
   
#     Set Test Variable  ${minNumberItem}   1

#     Set Test Variable  ${maxNumberItem}   5

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${CatalogId1}   ${resp.json()}

#     ${resp}=  Get Order Catalog    ${CatalogId1}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
    
#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME14}  
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Test Variable  ${pcid1}   ${resp1.json()}
#     ELSE
#         Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
#     END

#     ${DAY1}=  get_date
#     ${C_firstName}=   FakerLibrary.first_name 
#     ${C_lastName}=   FakerLibrary.name 
#     ${C_num1}    Random Int  min=123456   max=999999
#     ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
#     Set Test Variable  ${C_email}  ${C_firstName}${CUSERNAME14}.ynwtest@netvarth.com
#     ${homeDeliveryAddress}=   FakerLibrary.name 
#     ${city}=  FakerLibrary.city
#     ${landMark}=  FakerLibrary.Sentence   nb_words=2 
#     ${address}=  Create Dictionary   phoneNumber=${CUSERNAME14}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
#     Set Suite Variable  ${address}

#     ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
#     ${firstname}=  FakerLibrary.first_name
#     Set Test Variable  ${email}  ${firstname}${CUSERNAME14}.ynwtest@netvarth.com
#     ${orderNote}=  FakerLibrary.Sentence   nb_words=5
   
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME91}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${pcid1}   ${pcid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERNAME14}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${orderid1}  ${orderid[0]}

#     ${resp}=   Get Order by uid     ${orderid1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
#     Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
#     Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
#     Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
#     ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
#     ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
#     Set Suite Variable   ${totalPrice1}

#     ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
#     ${total}=  Convert To Number  ${total}  1

#     ${resp}=  Get Bill By UUId  ${orderid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

#     ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid1}  ${resp.json()['id']}
#     Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
#     ${resp}=  Make payment Consumer Mock  ${account_id1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${self}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
#     Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

#     ${resp}=  ConsumerLogout
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  ProviderLogin  ${PUSERNAME91}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Server Time
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${Date}    ${resp.json()}   
#     ${Date} =	Convert Date	${Date}	 result_format=%d/%m/%Y %I:%M %p

#     ${filter}=  Create Dictionary 
#     ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${token_id}   ${resp.json()}

#     ${resp}=  Get Report Status By Token Id  ${token_id}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['1']}   ${Date}                
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['3']}   ${countryCodes[0]}${CUSERNAME14}              
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['5']}   ${bookingType[3]}    ignore_case=True         
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['7']}   ${ordernumber}              
#     Variable Should Exist   ${resp.json()['reportContent']['data'][0]['10']}  ${total}
#     Variable Should Exist   ${resp.json()['reportContent']['data'][0]['15']}  ${total}


# JD-TC-orderreport-3
    
#     [Documentation]   take an online order(today, without prepayment) by a provider then 
#     ...   then generate order report and verify. 

#     ${resp}=  ProviderLogin  ${PUSERNAME92}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
#     Set Test Variable  ${pid1}  ${resp.json()['id']}

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id1}  ${resp.json()['id']}

#     ${highest_package}=  get_highest_license_pkg
#     Log  ${highest_package}
#     Set Suite variable  ${lic2}  ${highest_package[0]}

#     ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
#     Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
#     Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

#     clear_queue    ${PUSERNAME92}
#     clear_service  ${PUSERNAME92}
#     clear_Item   ${PUSERNAME92}

#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     Set Test Variable  ${email_id}  ${firstname}${PUSERNAME92}.ynwtest@netvarth.com

#     ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
  
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

#     ${resp}=  Get Account Payment Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${displayName1}=   FakerLibrary.name 
#     ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
#     ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
#     ${price1}=  Random Int  min=50   max=300 
#     ${price1}=  Convert To Number  ${price1}  1
#     ${price1float}=  twodigitfloat  ${price1}
#     ${itemName1}=   FakerLibrary.name  
#     ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
#     ${promoPrice1}=  Random Int  min=10   max=${price1} 
#     ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
#     ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

#     ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
#     ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

#     ${note1}=  FakerLibrary.Sentence   

#     ${itemCode1}=   FakerLibrary.word 

#     ${promoLabel1}=   FakerLibrary.word 

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id1}  ${resp.json()}

#     ${startDate}=  get_date
#     ${endDate}=  add_date  10      

#     ${startDate1}=  get_date
#     ${endDate1}=  add_date  15      

#     ${noOfOccurance}=  Random Int  min=0   max=0

#     ${sTime1}=  add_time  0  15
#     ${eTime1}=  add_time   3  30 
#     ${list}=  Create List  1  2  3  4  5  6  7
  
#     ${deliveryCharge}=  Random Int  min=50   max=100
#     ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

#     ${Title}=  FakerLibrary.Sentence   nb_words=2 
#     ${Text}=  FakerLibrary.Sentence   nb_words=4

#     ${minQuantity}=  Random Int  min=1   max=30
#     ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
   
#     ${catalogName}=   FakerLibrary.name  
#     ${catalogDesc}=   FakerLibrary.name 
#     ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

#     ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
#     ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

#     ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
#     ${timeSlots}=  Create List  ${timeSlots1}
#     ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
#     ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

#     ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

#     ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

#     ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
#     ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

#     ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
#     ${item}=  Create Dictionary  itemId=${item_id1}    
#     ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
#     ${catalogItem}=  Create List   ${catalogItem1}
  
#     Set Test Variable  ${orderType}       ${OrderTypes[0]}
#     Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
#     Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

#     ${advanceAmount}=  Random Int  min=1   max=1000
   
#     ${far}=  Random Int  min=14  max=14
   
#     ${soon}=  Random Int  min=0   max=0
   
#     Set Test Variable  ${minNumberItem}   1

#     Set Test Variable  ${maxNumberItem}   5

#     ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${CatalogId1}   ${resp.json()}

#     ${resp}=  Get Order Catalog    ${CatalogId1}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
    
#     ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME12}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${DAY1}=  get_date
#     ${C_firstName}=   FakerLibrary.first_name 
#     ${C_lastName}=   FakerLibrary.name 
#     ${C_num1}    Random Int  min=123456   max=999999
#     ${CUSERPH1}=  Evaluate  ${CUSERNAME}+${C_num1}
#     Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH1}.ynwtest@netvarth.com
#     ${homeDeliveryAddress}=   FakerLibrary.name 
#     ${city}=  FakerLibrary.city
#     ${landMark}=  FakerLibrary.Sentence   nb_words=2 
#     ${address}=  Create Dictionary   phoneNumber=${CUSERNAME12}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
#     Set Test Variable  ${address}

#     ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
#     ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
#     ${firstname}=  FakerLibrary.first_name
#     Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.ynwtest@netvarth.com
#     ${EMPTY_List}=  Create List

#     ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${orderid1}  ${orderid[0]}

#     ${resp}=   Get Order By Id    ${account_id1}   ${orderid1}   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  ProviderLogin  ${PUSERNAME92}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    
#     ${resp}=   Get Order by uid     ${orderid1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
#     Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
#     Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
#     Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
#     ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
#     ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
#     Set Suite Variable   ${totalPrice1}

#     ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
#     ${total}=  Convert To Number  ${total}  1

#     ${resp}=  Get Bill By UUId  ${orderid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

#     ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid1}  ${resp.json()['id']}
#     Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

#     ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
#     ${resp}=  ConsumerLogout
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  ProviderLogin  ${PUSERNAME92}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Server Time
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${Date}    ${resp.json()}   
#     ${Date} =	Convert Date	${DAY1}	 result_format=%d/%m/%Y %I:%M %p

#     ${filter}=  Create Dictionary 
#     ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${token_id}   ${resp.json()}

#     ${resp}=  Get Report Status By Token Id  ${token_id}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()['reportContent']['data']}   []                

JD-TC-orderreport-4
    
    [Documentation]   take an online order(today, with prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 

    ${resp}=  ProviderLogin  ${PUSERNAME93}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue    ${PUSERNAME93}
    clear_service  ${PUSERNAME93}
    clear_Item   ${PUSERNAME93}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME93}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float}=  twodigitfloat  ${price1}
    ${itemName1}=   FakerLibrary.name  
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30 
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=10  max=100
    ${advanceAmount}=  Convert To Number  ${advanceAmount}  1
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH1}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH1}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME15}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME15}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id1}    ${self}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  ProviderLogin  ${PUSERNAME93}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    
    # ${resp}=   Get Order by uid     ${orderid2} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    # Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid2}
    # Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    # Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    # ${resp}=  Get Bill By UUId  ${orderid2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    # Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}
    Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

    # ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[1]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${advanceAmount} 

    ${resp}=   Get Order By Id    ${account_id1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME93}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get Bill By consumer  ${orderid2}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 

    ${total}=  Evaluate  ${total} - ${advanceAmount}
    ${total}=  Convert To Number  ${total}  1
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[1]} 
    # Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${advanceAmount} 

    ${resp}=   Get Order By Id    ${account_id1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME93}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${Date}    ${resp.json()}   
    ${Date} =	Convert Date	${Date}	 result_format=%d/%m/%Y %I:%M %p

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['1']}   ${Date}                
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['2']}   ${cons_name1}              
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['3']}   ${countryCodes[0]}${CUSERNAME12}              
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['5']}   ${bookingType[3]}    ignore_case=True         
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['7']}   ${ordernumber}              
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['10']}  ${advanceAmount}
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['15']}  ${advanceAmount}
*** comment ***

JD-TC-orderreport-5

    [Documentation]   take an walkin order(today, with prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 

    ${resp}=  ProviderLogin  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue    ${PUSERNAME94}
    clear_service  ${PUSERNAME94}
    clear_Item   ${PUSERNAME94}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME94}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float}=  twodigitfloat  ${price1}
    ${itemName1}=   FakerLibrary.name  
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30 
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[1]}

    ${advanceAmount}=  Random Int  min=10  max=100
    ${advanceAmount}=  Convert To Number  ${advanceAmount}  1
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERNAME10}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME10}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Suite Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME10}.ynwtest@netvarth.com
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${pcid1}   ${pcid1}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERNAME14}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}
    Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${advanceAmount}  ${purpose[0]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME94}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${Date}    ${resp.json()}   
    ${Date} =	Convert Date	${Date}	 result_format=%d/%m/%Y %I:%M %p

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['1']}   ${Date}                
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['2']}   ${cons_name1}              
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['3']}   ${countryCodes[0]}${CUSERNAME12}              
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['5']}   ${bookingType[3]}    ignore_case=True         
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['7']}   ${ordernumber}              
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['10']}  ${advanceAmount}
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['15']}  ${advanceAmount}

*** comment ***
JD-TC-orderreport-6

    [Documentation]   take a walkin order for a family member(today, without prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 

    ${resp}=  ProviderLogin  ${PUSERNAME95}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_queue    ${PUSERNAME95}
    clear_service  ${PUSERNAME95}
    clear_Item   ${PUSERNAME95}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME95}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float}=  twodigitfloat  ${price1}
    ${itemName1}=   FakerLibrary.name  
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30 
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${firstname0}=  FakerLibrary.first_name
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Set Test Variable  ${mem_id0}  ${resp.json()}

    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERNAME14}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME14}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME14}.ynwtest@netvarth.com
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME95}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${pcid1}   ${mem_id0}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}   ${eTime1}   ${DAY1}    ${CUSERNAME14}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}
    Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${total}  ${purpose[1]}  ${orderid1}  ${EMPTY}  ${bool[0]}   ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmountPaid']}    ${total} 

    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME95}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${Date}    ${resp.json()}   
    ${Date} =	Convert Date	${Date}	 result_format=%d/%m/%Y %I:%M %p

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['1']}   ${Date}                
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['3']}   ${countryCodes[0]}${CUSERNAME14}              
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['5']}   ${bookingType[3]}    ignore_case=True         
    Should Be Equal As Strings   ${resp.json()['reportContent']['data'][0]['7']}   ${ordernumber}              
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['10']}  ${total}
    Variable Should Exist   ${resp.json()['reportContent']['data'][0]['15']}  ${total}


JD-TC-orderreport-7

    [Documentation]   take an online order for a family member(today, without prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 


    ${resp}=  ProviderLogin  ${PUSERNAME96}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue    ${PUSERNAME96}
    clear_service  ${PUSERNAME96}
    clear_Item   ${PUSERNAME96}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME96}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1}=  Convert To Number  ${price1}  1
    ${price1float}=  twodigitfloat  ${price1}
    ${itemName1}=   FakerLibrary.name  
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1}=  Convert To Number  ${promoPrice1}  1
    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  get_date
    ${endDate}=  add_date  10      

    ${startDate1}=  get_date
    ${endDate1}=  add_date  15      

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_time  0  15
    ${eTime1}=  add_time   3  30 
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge}=  Convert To Number  ${deliveryCharge}  1

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30
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

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item}=  Create Dictionary  itemId=${item_id1}    
    ${catalogItem1}=  Create Dictionary  item=${item}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
  
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=0   max=0
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  get_date
    ${C_firstName}=   FakerLibrary.first_name 
    ${C_lastName}=   FakerLibrary.name 
    ${C_num1}    Random Int  min=123456   max=999999
    ${CUSERPH1}=  Evaluate  ${CUSERNAME}+${C_num1}
    Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH1}.ynwtest@netvarth.com
    ${homeDeliveryAddress}=   FakerLibrary.name 
    ${city}=  FakerLibrary.city
    ${landMark}=  FakerLibrary.Sentence   nb_words=2 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME12}    firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
    Set Test Variable  ${address}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
    ${item_quantity11}=  Convert To Number  ${item_quantity1}  1
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME12}.ynwtest@netvarth.com
    ${EMPTY_List}=  Create List

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id1}    ${mem_id}    ${CatalogId1}     ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME12}    ${email}  ${countryCodes[0]}  ${EMPTY_List}  ${item_id1}    ${item_quantity1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id    ${account_id1}   ${orderid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ProviderLogin  ${PUSERNAME96}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_id1}  ${resp.json()[0]['id']}
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]} 
  
    ${totalPrice1}=  Evaluate  ${item_quantity1} * ${promoPrice1}
    ${totalPrice1}=  Convert To Number  ${totalPrice1}  1
    Set Suite Variable   ${totalPrice1}

    ${total}=  Evaluate  ${totalPrice1} + ${deliveryCharge}
    ${total}=  Convert To Number  ${total}  1

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netTotal']}           ${totalPrice1} 
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[0]} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}          ${total} 

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}
    Set Test Variable  ${cons_name1}  ${resp.json()['userName']}

    ${resp}=  Get Bill By consumer  ${orderid1}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${total} 
    
    ${resp}=  ConsumerLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME96}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Server Time
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${Date}    ${resp.json()}   
    ${Date} =	Convert Date	${DAY1}	 result_format=%d/%m/%Y %I:%M %p

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType[4]}  ${dateCategory[0]}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['reportContent']['data']}   []                

*** comment ***
JD-TC-orderreport-8

    [Documentation]   take an online ord er for a family member(today, with prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 


JD-TC-orderreport-9

    [Documentation]   take a walkin order for a family member(today, with prepayment) by a provider then 
    ...   do the pre payment then generate order report and verify. 


JD-TC-orderreport-10

    [Documentation]   take a walkin order for a consumer(today, without prepayment) by a provider then 
    ...   do the bill payment then generate order report after that consumer cancel the booking then
    ...   verify the report. 
