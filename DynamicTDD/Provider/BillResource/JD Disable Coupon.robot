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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${coupon1}  wheat1
${coupon2}  wheat2
${coupon3}  wheat3
${coupon4}  wheat4
${coupon5}  wheat5
${cnote}   hi
${start}  90

*** Test Cases ***
JD-TC-Disable coupon-1
    [Documentation]   Provider check to Disable coupon 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERNAME211}

    # ${desc1}=  FakerLibrary.Sentence   nb_words=2
    # ${amount1}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type1}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon1}  ${desc1}  ${amount1}  ${type1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${value1}   ${resp.json()}
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    
    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
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
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${value1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${value1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[0]}

    ${resp}=  Disable Coupon  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Coupon By Id  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[1]}

JD-TC-Disable coupon-UH1

    [Documentation]   Disable a already disabled coupon

    ${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Coupon  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_DISABLED}"
        
JD-TC-Disable coupon-UH2

    [Documentation]    Consumer check to Disable coupon  

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Coupon  ${value1}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Disable coupon-UH3

    [Documentation]  Disable coupon   without login 

    ${resp}=  Disable Coupon  ${value1}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"   
    
JD-TC-Disable coupon-UH4

    [Documentation]   Provider check to Disable coupon  with invalid coupon id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME220}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Coupon  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_COUPON_ID}" 
    
JD-TC-Disable coupon-UH5

    [Documentation]    Disable coupon  with another provider coupon id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME220}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Coupon  ${value1}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}" 
    

JD-TC-Disable coupon-2

    [Documentation]  try to Disable coupon that is on bill

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${start}  ${length}    
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${domain}=   Set Variable    ${resp.json()['sector']}
        ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Log   ${resp2.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Exit For Loop If     '${check}' == 'True'  
    END
    Set Suite Variable  ${a}
    # ${resp}=   Encrypted Provider Login  ${PUSERNAME220}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
    clear_Coupon   ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}

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
    # ${resp}=  Create Coupon  ${coupon2}  ${desc}  ${amount}  ${calctype[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${couponId}  ${resp.json()}
    clear_location  ${PUSERNAME${a}}
    ${resp} =  Create Sample Queue
    Set Suite Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=1  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=10  max=100
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

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}      

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  ${cnote}  ${bool[1]}  ${cId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Disable coupon  ${couponId}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Coupon By Id  ${couponId}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[1]}
    
JD-TC-Disable coupon-3

    [Documentation]  try to Disable coupon when coupon is on setled bill

    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200


    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${resp}=  Create Coupon  ${coupon3}  ${desc}  ${amount}  ${calctype[0]}
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
    Set Test Variable  ${couponId}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}   

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Set Test Variable  ${bid}  ${resp.json()['id']}

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${tamount}  ${resp.json()['amountDue']} 
    ${resp}=  Accept Payment  ${wid}  cash  ${tamount}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable coupon  ${couponId}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Coupon By Id  ${couponId}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[1]}    
        
    
    
   
    
   