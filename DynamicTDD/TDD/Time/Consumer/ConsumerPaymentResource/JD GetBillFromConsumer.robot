*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py



*** Variables ***

${self}         0
@{empty_list} 

*** Test Cases ***

JD-TC-GetBillFromConsumer-1
    
    [Documentation]  Take an online Appointment for a prepayment service(today), then do the prepayment.
    ...   take an online appointment by the same consumer(next day), then do the prepayment and bill payment. 
    ...   generate bill after 5 days then verify it.

    clear_location   ${PUSERNAME110}
    clear_service    ${PUSERNAME110}
    clear_queue      ${PUSERNAME110}
    clear_customer   ${PUSERNAME110}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${service_duration}=   Random Int   min=2   max=10

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${consid}  ${resp.json()['id']}
    
    ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    # ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    # Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    # Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    # Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    change_system_date  1


    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
   
    ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${DAY2}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${balamount1}  ${purpose[1]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date  7

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-GetBillFromConsumer-2
    
    [Documentation]  Take an online Appointment for a prepayment service(today), then do the prepayment.
    ...   take an online appointment by the same consumer(next day), then do the prepayment and bill payment. 
    ...   generate bill after 5 days then verify it.

    clear_location   ${PUSERNAME111}
    clear_service    ${PUSERNAME111}
    clear_queue      ${PUSERNAME111}
    clear_customer   ${PUSERNAME111}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${service_duration}=   Random Int   min=2   max=10

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}  
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    change_system_date  7

    ${day3}=   db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-GetBillFromConsumer-3
    
    [Documentation]  Taking online check in with prepayment and coupon amount as the service amount
    ...  then cancel the waitlist by consumer and check refund.

    clear_location   ${PUSERNAME151}
    clear_service    ${PUSERNAME151}
    clear_queue      ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Tot}=   Random Int   min=100   max=500
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${service_duration}=   Random Int   min=2   max=5
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Evaluate   ${Tot1}-${min_pre1}
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${ser_id1}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME10}
    
    ${DAY3}=   db.add_timezone_date  ${tz}  1  
    ${msg}=  FakerLibrary.word
    ${coupons}=  Create List  ${cupn_code}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY3}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount1}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                       ${balamount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}                     ${paymentStatus[2]}

    sleep   2s
    ${resp}=   Cancel Waitlist  ${cwid}  ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    change_system_date  5

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

