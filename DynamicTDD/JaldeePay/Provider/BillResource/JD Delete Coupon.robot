*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***

${start}         170

*** Test Cases ***
JD-TC-Delete Coupon-1
    [Documentation]  Provider check to delete coupon 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME129}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERNAME129}
    clear_service   ${PUSERNAME129}
    # clear_location  ${PUSERNAME129}
    clear_appt_schedule   ${PUSERNAME129}
    clear_customer   ${PUSERNAME129}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid1}  ${resp.json()}

    ${description1}=  FakerLibrary.sentence
    ${ser_durtn1}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE2}   ${description1}   ${ser_durtn1}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid2}  ${resp.json()}

    ${description2}=  FakerLibrary.sentence
    ${ser_durtn2}=   Random Int   min=2   max=10
    ${ser_amunt}=   Random Int   min=100   max=1000
    ${ser_amunt2}=   Convert To Number   ${ser_amount}
    ${SERVICE3}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE3}   ${description2}   ${ser_durtn2}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amunt2}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid3}  ${resp.json()}

    ${description3}=  FakerLibrary.sentence
    ${ser_durtn3}=   Random Int   min=2   max=10
    ${ser_amount3}=   Random Int   min=100   max=1000
    ${ser_amount3}=   Convert To Number   ${ser_amount}
    ${SERVICE4}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE4}   ${description3}   ${ser_durtn3}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount3}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid4}  ${resp.json()}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
     
    ${coupon1}=    FakerLibrary.word
    ${desc1}=  FakerLibrary.Sentence   nb_words=2
    ${amount1}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc1}  ${amount1}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${coupon_id1}  ${resp.json()}

    ${coupon2}=    FakerLibrary.word
    ${desc2}=  FakerLibrary.Sentence   nb_words=2
    ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid3}   
    ${resp}=  Create Provider Coupon   ${coupon2}  ${desc2}  ${amount2}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id2}  ${resp.json()}

    ${coupon3}=    FakerLibrary.word
    ${desc3}=  FakerLibrary.Sentence   nb_words=2
    ${amount3}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid3}  ${sid4} 
    ${resp}=  Create Provider Coupon   ${coupon3}  ${desc3}  ${amount3}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id3}  ${resp.json()}
    
    # ${desc1}=  FakerLibrary.Sentence   nb_words=2
    # ${amount1}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type1}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon1}  ${desc1}  ${amount1}  ${type1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${desc2}=  FakerLibrary.Sentence   nb_words=2
    # ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type2}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon2}  ${desc2}  ${amount2}  ${type2}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${value}   ${resp.json()}
    # ${desc3}=  FakerLibrary.Sentence   nb_words=2
    # ${amount3}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type3}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon3}  ${desc3}  ${amount3}  ${type3}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${value1}   ${resp.json()}
    ${resp}=   Get Coupons  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${count}  3
    Verify Response List   ${resp}  0    name=${coupon1}  description=${desc1}  amount=${amount1}  calculationType=${calctype[1]}  status=${status[0]}
    Verify Response List   ${resp}  1    name=${coupon2}  description=${desc2}  amount=${amount2}  calculationType=${calctype[1]}  status=${status[0]}
    Verify Response List   ${resp}  2    name=${coupon3}  description=${desc3}  amount=${amount3}  calculationType=${calctype[1]}  status=${status[0]}
    
    ${resp}=  Delete Coupon  ${coupon_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Coupons 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${count}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${count}  2
    Verify Response List   ${resp}  0    name=${coupon1}  description=${desc1}  amount=${amount1}  calculationType=${calctype[1]}  status=${status[0]}
    Verify Response List   ${resp}  1    name=${coupon2}  description=${desc2}  amount=${amount2}  calculationType=${calctype[1]}  status=${status[0]}
        
JD-TC-Delete Coupon-UH1 

    [Documentation]   Consumer check to delete coupon  

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Coupon  ${coupon_id1}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"   

JD-TC-Delete Coupon-UH2

    [Documentation]  delete coupon   without login 

    ${resp}=  Delete Coupon  ${coupon_id1}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"   
    
JD-TC-Delete Coupon-UH3

    [Documentation]  Provider check to delete coupon  with invalid coupon id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME129}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Coupon  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_COUPON_ID}" 
    
JD-TC-Delete Coupon-UH4

    [Documentation]   delete coupon  with another provider's coupon id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Coupon  ${coupon_id1}   
    Should Be Equal As Strings  ${resp.status_code}  422

    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}" 
    

JD-TC-Delete Coupon-UH5

    [Documentation]  try to delete coupon that is on bill
    comment  Try to delet coupon when coupon is remove from the bill by update

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
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon4}  ${desc}  ${amount}  ${calctype[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${couponId}  ${resp.json()}
    clear_location  ${PUSERNAME${a}}
    clear_service   ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}
    Set Suite Variable    ${a}
    ${resp} =  Create Sample Queue
    Set Suite Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}   

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=1  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}   0   30
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=75   max=100
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}  
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupons}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  ${action[12]}   ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    

    # ${resp}=  Delete Coupon  ${couponId}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200    
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Contain  "${resp.json()}"  "${COUPON_IS_IN_BILL}"

    ${resp}=  Update Bill   ${wid}  ${action[13]}   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Coupon  ${couponId}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Coupon By Id  ${couponId}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"      
    
JD-TC-Delete Coupon-UH6

    [Documentation]  try to delete coupon when coupon is on setled bill

    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon5}  ${desc}  ${amount}  ${calctype[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${couponId}  ${resp.json()}
    
    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=1  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=10   max=100
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}  
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}


    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}   
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  ${action[12]}   ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}

    ${resp}=  Delete Coupon  ${couponId}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    Should Be Equal As Strings  ${resp.status_code}  422
    Should Contain  "${resp.json()}"  "${COUPON_IS_IN_BILL}"
    
    ${resp}=  Accept Payment  ${wid}  cash  ${amount}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Delete Coupon  ${couponId}
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"
    
   
    
   