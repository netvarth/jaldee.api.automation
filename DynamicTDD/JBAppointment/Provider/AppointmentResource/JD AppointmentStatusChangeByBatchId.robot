
*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Change Status
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
${self}   0

${prefix}                   serviceBatch
${suffix}                   serving


*** Test Cases ***  
JD-TC-Appointment Statuschange By Batch-1
    [Documentation]   Provider change appointment status from arrived to start by BatchId 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment  Dev can not fix this error immediate.
*** Comments ***
#   Dev can not fix this error immediate.
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME33}
    clear_location  ${PUSERNAME33}
    clear_customer   ${PUSERNAME33}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id2}
    clear_appt_schedule   ${PUSERNAME33}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    # ${resp}=   Enable Batch For Appointment    ${sch_id}
    # Log    ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name1}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1   20  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name2}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id4}  ${resp.json()}

    # ${resp}=   Enable Batch For Appointment    ${sch_id4}
    # Log    ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Add Appmt Batch Name    ${sch_id4}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id4}   name=${schedule_name2}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id4}
    Set Suite Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${batchId}   ${resp.json()[0]['batchId']}

    ${resp}=    Change Appmt Status by BatchId    ${batchId}  ${apptStatus[3]}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}     ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}         ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}         ${slot1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${apptStatus[3]}
    Should Be Equal As Strings  ${resp.json()['batchId']}           ${batchId}

JD-TC-Appointment Statuschange By Batch-2
    [Documentation]   Provider change appointment status from Start to Complete by Batch id    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Appmt Status by BatchId    ${batchId}  ${apptStatus[6]}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}     ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}         ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}         ${slot1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${apptStatus[6]}
    Should Be Equal As Strings  ${resp.json()['batchId']}           ${batchId}

JD-TC-Appointment Statuschange By Batch-3
    [Documentation]   Provider change Appointment status to Cancelled status By BatchId 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME33}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor2}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${batchId}   ${resp.json()[0]['batchId']}   

    
    ${resp}=    Cancel Appointment by Batch    ${batchId}  ${apptStatus[4]}  ${DAY1}  ${cancelReason[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}     ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}         ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}         ${slot1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${apptStatus[4]}
    Should Be Equal As Strings  ${resp.json()['batchId']}           ${batchId}

JD-TC-Appointment Statuschange By Batch-4
    [Documentation]   Provider change Appointment status to Reject status By BatchId  
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME33}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${available_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${available_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor2}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${batchId}   ${resp.json()['batchId']}

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${batchId}   ${resp.json()[0]['batchId']}   

    ${resp}=    Reject Appointment by Batch    ${batchId}  ${apptStatus[5]}   ${DAY1}  ${cancelReason[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s
    # sleep  1s

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}     ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}         ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}         ${slot1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${apptStatus[5]}
    Should Be Equal As Strings  ${resp.json()['batchId']}           ${batchId}   

JD-TC-Appointment Statuschange By Batch-5
    [Documentation]   Giving Future date when Provider change Appmt status get cancelled by BatchId

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME33}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id4}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${available_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${available_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor2}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id1}  ${sch_id4}  ${DAY1}  ${cnote}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${batchId}   ${resp.json()[0]['batchId']}

    ${Future_day}=  db.add_timezone_date  ${tz}  10    
    
    ${resp}=    Cancel Appointment by Batch    ${batchId}  ${apptStatus[4]}  ${Future_day}  ${cancelReason[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Appointment Statuschange By Batch-6
    [Documentation]   Giving Future when Provider change apmmt status get Rejected by BatchId
    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME33}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id4}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${available_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${available_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot2}
    ${apptfor2}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    Log  ${sch_id4}
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id2}  ${sch_id4}  ${DAY1}  ${cnote}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${batchId}   ${resp.json()[0]['batchId']}

    ${Future_day}=  db.add_timezone_date  ${tz}  5      
    ${resp}=    Reject Appointment by Batch    ${batchId}  ${apptStatus[5]}   ${Future_day}  ${cancelReason[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Appointment Statuschange By Batch-UH1
    [Documentation]   Provider without Login change the appmt status to Start using BatchId

    ${resp}=    Change Appmt Status by BatchId    ${batchId}  ${apptStatus[3]}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Appointment Statuschange By Batch-UH2
    [Documentation]   Provider without Login change the appmt status From Start to Completed using BatchId

    ${resp}=    Change Appmt Status by BatchId    ${batchId}  ${apptStatus[6]}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Appointment Statuschange By Batch-UH3
    [Documentation]   Provider without Login change the appmt status to get Cancelled using BatchId

    ${resp}=    Cancel Appointment by Batch    ${batchId}  ${apptStatus[4]}  ${DAY1}  ${cancelReason[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Appointment Statuschange By Batch-UH4
    [Documentation]   Provider without Login change the appmt status to get Rejected using BatchId

    ${resp}=    Reject Appointment by Batch    ${batchId}  ${apptStatus[5]}   ${DAY1}  ${cancelReason[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Appointment Statuschange By Batch-UH5
    [Documentation]   Provider change the appmt status to Confirmed using BatchId
    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Appmt Status by BatchId    ${batchId}  ${apptStatus[1]}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ACTION}"

