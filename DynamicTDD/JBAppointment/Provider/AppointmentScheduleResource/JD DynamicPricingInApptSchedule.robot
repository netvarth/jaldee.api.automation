*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
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


JD-TC-DynamicPricingInSchedule-1

    [Documentation]  Taking Appointment from consumer side for a prepayment service with dynamic pricing in schedule. 
    ...  verify the service price from consumer side in both schedules.

    clear_location   ${PUSERNAME112}
    clear_service    ${PUSERNAME112}
    clear_queue      ${PUSERNAME112}
    clear_customer   ${PUSERNAME112} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
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
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

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
    Set Suite variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    Set Suite Variable  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${service_duration}=   Random Int   min=2   max=6
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}  prePaymentType=${advancepaymenttype[1]}  priceDynamic=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}

    ${resp}=  Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  5  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${dyn_ser_price1}=   Random Int   min=100   max=200
    ${dyn_ser_price1}=  Convert To Number  ${dyn_ser_price1}  1
    ${resp}=   Set Price Variation Per Schedule    ${sch_id2}  ${ser_id1}  ${dyn_ser_price1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Price Variation Per Schedule     ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}              ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['price']}                       0.0
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}              ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[1]['price']}                       ${dyn_ser_price1}
    
    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

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
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
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

    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${Tot1}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${Tot1}
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}
    
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

    @{slots}=  Create List

    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END

    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}  

    ${nettotal}=  Evaluate  ${Tot1}+${dyn_ser_price1}
    ${nettotal}=  Convert To Number  ${nettotal}  1
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${nettotal}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${nettotal}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${nettotal}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${apptid2}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid2}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${nettotal}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${nettotal}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${nettotal}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}


JD-TC-DynamicPricingInSchedule-2

    [Documentation]  Taking Appointment from consumer side for a prepayment service with tax(5%) and dynamic pricing in schedule. 
    ...  verify the service price from consumer side in both schedules.

    clear_location   ${PUSERNAME113}
    clear_service    ${PUSERNAME113}
    clear_queue      ${PUSERNAME113}
    clear_customer   ${PUSERNAME113} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[0]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

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
    ${DAY2}=  db.add_timezone_date  ${tz}  12 
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    Set Suite Variable  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${service_duration}=   Random Int   min=2   max=6
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}  prePaymentType=${advancepaymenttype[1]}  priceDynamic=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}

    ${resp}=  Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  5  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${dyn_ser_price1}=   Random Int   min=100   max=200
    ${dyn_ser_price1}=  Convert To Number  ${dyn_ser_price1}  1
    ${resp}=   Set Price Variation Per Schedule    ${sch_id2}  ${ser_id1}  ${dyn_ser_price1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Price Variation Per Schedule     ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}              ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['price']}                       0.0
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}              ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[1]['price']}                       ${dyn_ser_price1}
    
    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

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
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
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

    ${tax}=  Evaluate  ${Tot1}*${gstpercentage[0]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${tax_amount}=  Evaluate  ${tax}+${Tot1}
    ${balamount}=  Evaluate  ${tax_amount}-${min_pre1}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}        ${tax}
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
 
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

    @{slots}=  Create List

    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END

    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}  
    
    ${nettotal}=  Evaluate  ${Tot1}+${dyn_ser_price1}
    ${nettotal}=  Convert To Number  ${nettotal}  1
    ${tax}=  Evaluate  ${nettotal}*${gstpercentage[0]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${tax_amount}=  Evaluate  ${tax}+${nettotal}
    ${balamount}=  Evaluate  ${tax_amount}-${min_pre1}
    ${balamount}=  Convert To Number  ${balamount}  2
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${nettotal}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${resp}=  Get Bill By consumer  ${apptid2}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid2}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${nettotal}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${nettotal}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}


JD-TC-DynamicPricingInSchedule-3

    [Documentation]  Taking Appointment from consumer side for a prepayment service with tax(5%) and dynamic pricing in schedule. 
    ...  verify the service price from consumer side in both schedules and do the bill payemtn and verify the payment report.

    clear_location   ${PUSERNAME114}
    clear_service    ${PUSERNAME114}
    clear_queue      ${PUSERNAME114}
    clear_customer   ${PUSERNAME114} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[0]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

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
    ${DAY2}=  db.add_timezone_date  ${tz}  12 
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    Set Suite Variable  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${service_duration}=   Random Int   min=2   max=6
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}  prePaymentType=${advancepaymenttype[1]}  priceDynamic=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}

    ${resp}=  Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  5  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${dyn_ser_price1}=   Random Int   min=100   max=200
    ${dyn_ser_price1}=  Convert To Number  ${dyn_ser_price1}  1
    ${resp}=   Set Price Variation Per Schedule    ${sch_id2}  ${ser_id1}  ${dyn_ser_price1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Price Variation Per Schedule     ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}              ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['price']}                       0.0
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}              ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}               ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[1]['price']}                       ${dyn_ser_price1}
    
    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

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
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
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

    ${tax}=  Evaluate  ${Tot1}*${gstpercentage[0]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${tax_amount}=  Evaluate  ${tax}+${Tot1}
    ${balamount}=  Evaluate  ${tax_amount}-${min_pre1}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}        ${tax}
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}

    sleep   2s

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${balamount}  ${purpose[1]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
 
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

    @{slots}=  Create List

    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END

    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}  
    
    ${nettotal}=  Evaluate  ${Tot1}+${dyn_ser_price1}
    ${nettotal}=  Convert To Number  ${nettotal}  1
    ${tax}=  Evaluate  ${nettotal}*${gstpercentage[0]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${tax_amount}=  Evaluate  ${tax}+${nettotal}
    ${balamount1}=  Evaluate  ${tax_amount}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount1}  2
    
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id1}  ${ser_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}   ${min_pre1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}            ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['servicePrice']}        ${nettotal}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Bill By consumer  ${apptid2}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid2}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${nettotal}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${nettotal}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    sleep   2s

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${balamount1}  ${purpose[1]}  ${apptid2}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${resp}=  Get Bill By consumer  ${apptid2}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid2}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${nettotal}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${nettotal}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${tax_amount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  apptStatus=${apptStatus[1]}    paymentStatus=${paymentStatus[2]}
    

    ${resp}=  Get Appointment By Id  ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  apptStatus=${apptStatus[1]}    paymentStatus=${paymentStatus[2]}
    

    sleep   01s

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






*** Comments *** 

    ${resp}=  Get Appointment By Id  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  apptStatus=${apptStatus[1]}    paymentStatus=${paymentStatus[2]}
    
    Set Test Variable  ${paymentPurpose-eq2}      billPayment
    Set Test Variable  ${reportType}              PAYMENT
    Set Test Variable  ${reportDateCategory}      TODAY
  
    ${filter2}=  Create Dictionary  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[3]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c15}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}


    Should Be Equal As Strings  Payment Receipts         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    # Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['2']}  # CustomerName
    # Should Be Equal As Strings  ${CustomerName}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][0]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][0]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt1}        ${resp.json()['reportContent']['data'][0]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${balamount1}        ${resp.json()['reportContent']['data'][0]['10']}  # Amount_Paid
    # Should Be Equal As Strings  ${Gateway_fees}        ${resp.json()['reportContent']['data'][0]['10']}  # Gateway_fees
    # Should Be Equal As Strings  ${Service_fees_tax}        ${resp.json()['reportContent']['data'][0]['11']}  # Service_fees_tax
    # Should Be Equal As Strings  ${Jaldee_service_fees}        ${resp.json()['reportContent']['data'][0]['12']}  # Jaldee_service_fees
    # Should Be Equal As Strings  ${Net_Amount}        ${resp.json()['reportContent']['data'][0]['13']}  # Net_Amount
    # Should Be Equal As Strings  ${payref_balance1}        ${resp.json()['reportContent']['data'][0]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][0]['11']}  # Mode_of_tansaction
    # Should Be Equal As Strings  ${Bank}        ${resp.json()['reportContent']['data'][0]['16']}  # Bank
    Set Suite Variable  ${BillRef_id102}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId
    Should Be Equal As Strings  ${BillRef_id100}   ${BillRef_id102}
    Should Be Equal As Strings  ${Date_Time}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  Checkin/Token             ${resp.json()['reportContent']['data'][1]['5']}  # BookingType
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  ${c15_BillId1}        ${resp.json()['reportContent']['data'][1]['8']}  # Bill_Id
    Should Be Equal As Strings  ${totalamt1}        ${resp.json()['reportContent']['data'][1]['9']}  # Bill_Amount
    Should Be Equal As Strings  ${Pre_amount1}        ${resp.json()['reportContent']['data'][1]['10']}  # Amount_Paid
    # Should Be Equal As Strings  ${payref_pre1}        ${resp.json()['reportContent']['data'][1]['16']}  # Payment_Id
    Should Be Equal As Strings  ${payment_modes[5]}        ${resp.json()['reportContent']['data'][1]['11']}  # Mode_of_tansaction
    Set Suite Variable  ${BillRef_id101}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId
    Should Be Equal As Strings  ${BillRef_id101}   ${BillRef_id100}

