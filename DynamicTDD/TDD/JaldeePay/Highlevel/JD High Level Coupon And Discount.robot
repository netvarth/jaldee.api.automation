*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Discount  Coupon      
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${coupon}   onnnamH
${item1}  PenHHH
${itemCode1}   ItemCode1HHHH
${discount}  soapH
${start}  140
${start1}  220
${self}   0
${DisplayName1}   item1_DisplayName


*** Test Cases ***
JD-TC-High Level Test Case-1
    [Documentation]  Try to delete discount that is on bill
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${start}  ${length}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}  ${resp2.json()['serviceBillable']}
        Exit For Loop IF     "${check}" == "True"
    END
    Set Suite Variable   ${a}
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[0]}  Predefine
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${discountId}   ${resp.json()}
    clear_location   ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}
    clear_service   ${PUSERNAME${a}}

    ${resp} =  Create Sample Queue
    Set Suite Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cId}  ${resp.json()[0]['id']}

    # ${cId}=  get_id  ${CUSERNAME4}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  ${desc}  ${s_id}  1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addServiceLevelDiscount   ${service}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Delete Discount   ${discountId}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Contain   "${resp.json()}"   ${DISCOUNT_IS_IN_BILL}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amount}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200    

    Comment  delete coupon discount #success  
    ${resp}=   Delete Discount  ${discountId}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Comment  check  discount existing
    ${resp}=   Get Discount By Id   ${discountId} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"   


JD-TC-High Level Test Case-2  
    [Documentation]  try to delete  discount that appled to the item of the bill
    comment  setle the bill and remove coupon discount
    ${resp}=   Encrypted Provider Login   ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${des}=  FakerLibrary.Word
    ${description}=  FakerLibrary.sentence
    ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    # ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}    ${bool[0]}
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${amount1}  ${bool[1]}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[0]}  Predefine
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${discountId}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=  Item Bill  ${des}  ${itemId}   1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=  Item Bill  ${des}  ${itemId}   1  ${discountId}
    ${resp}=  Update Bill   ${wid}  addItemLevelDiscount   ${item}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Comment  try to delet coupon and discount #fail
    ${resp}=   Delete Discount  ${discountId}    
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_IS_IN_BILL}"
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amount}
    Comment  Settle bill
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Item By Id   ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200

    Comment  delete coupon ,discount,itam #success
    ${resp}=   Delete Item   ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Delete Discount  ${discountId}    
    Should Be Equal As Strings  ${resp.status_code}  200    

    Comment  check  discount existing
    ${resp}=   Get Discount By Id   ${discountId} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"

    ${resp}=   Get Item By Id   ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}  ${status[1]}

    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_ITEM_ID}"

JD-TC-High Level Test Case-3
    Comment  create bill 
    Comment  coupon discount applied to the whole bill
    comment  try to delete coupon discount
    Comment  update to remove coupon discount then  delete coupon,discount
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${start1}  ${length}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}  ${resp2.json()['serviceBillable']}
        Exit For Loop IF     "${check}" == "True"
    END

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${resp}=   Create Discount  ${discount}   ${desc}    ${amount}   ${calctype[0]}  Predefine
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${discountId}   ${resp.json()}

    
    # ${item_amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    ${item_amount}=  Set Variable    50.0
    Set Suite Variable    ${item_amount}
    # ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${item_amount}    ${bool[0]}
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${item_amount}  ${bool[0]}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id}  ${resp.json()}

    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${amount}  ${calctype[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${couponId}  ${resp.json()}
    
    clear_location   ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}
    clear_service   ${PUSERNAME${a}}

    ${resp} =  Create Sample Queue
    Set Suite Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}
    

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=150
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id} 
    ${items}=   Create List   ${item_id}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}
    ${disc1}=  Bill Discount Input  ${discountId}  ${desc}  ${desc}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
    ${resp}=  Update Bill   ${wid}  addBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  addProviderCoupons   ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  Delete Coupon  ${couponid}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_IS_IN_BILL}" 
    ${resp}=   Delete Discount  ${discountId}    
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DISCOUNT_IS_IN_BILL}"
    
    sleep   2s
    ${bdisc}=  Remove Bill Discount  ${bid}  ${discountId} 
    ${resp}=  Update Bill   ${wid}  removeBillLevelDiscount  ${bdisc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Bill   ${wid}  removeProviderCoupons   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Delete Coupon  ${couponId}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Delete Discount  ${discountId}    
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=  Get Coupon By Id  ${couponid} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"

    ${resp}=   Get Discount By Id   ${discountId} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_DISCOUNT_ID}"