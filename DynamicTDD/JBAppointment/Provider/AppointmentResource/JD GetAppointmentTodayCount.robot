*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Appointment  Today
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}  sampleservice33 
${SERVICE2}  sampleservice44
${self}     0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}


*** Test Cases ***
JD-TC-GetAppointmentTodayCount-1
    [Documentation]  Get provider's appointments today.
    ${pid}=  get_acc_id  ${PUSERNAME178}
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME7}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${Keys1}=  Get Dictionary Keys  ${resp.json()['slot']}   sort_keys=False 
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetAppointmentTodayCount-2
    [Documentation]  Get provider's appointments for service with prepayment but prepayment not done by consumer
    ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=90   max=100
    Log   ${billable_providers}
    Set Suite Variable   ${billable_providers}
    Log   ${multilocPro}
    Set Suite Variable   ${multilocPro}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    # ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    Set Test Variable  ${accountId1}  ${resp.json()['accountId']}

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot1}   ${Keys[0]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[0]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetAppointmentTodayCount-3
    [Documentation]  Get provider's appointments for service with prepayment after prepayment
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pan_num}=   db.Generate_pan_number
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payuVerify  ${pid}
    Log  ${resp}

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot1}   ${Keys[0]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${min_pre}  ${bool[1]}  ${apptid1}  ${pid}  ${purpose[0]}   ${cid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()['merchantId']}  ${merchantid}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${billable_providers[3]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid1}  ${pid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${cid}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}  
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${cid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  apptStatus=${apptStatus[1]}   paymentStatus=${paymentStatus[1]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=CONSUMER   paymentStatus=${paymentStatus[1]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-4
    [Documentation]  Get provider's appointments today with appointment status confirmed
    ${pid}=  get_acc_id  ${PUSERNAME178}
    # ${cid}=  get_id  ${CUSERNAME15}
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2


JD-TC-GetAppointmentTodayCount-5
    [Documentation]  Get provider's appointments today with appointment status CONFIRMED
        ${pid}=  get_acc_id  ${PUSERNAME178}
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetAppointmentTodayCount-6
    [Documentation]  Get provider's appointments today with appointment status Started
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    Comment   ${CUSERNAME15} has taken appointment for this provider from consumer side in the last 5 cases.

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}

    # ${resp}=  AddCustomer  ${CUSERNAME15}  firstName=${fname2}   lastName=${lname2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[3]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[3]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-7
    [Documentation]  Get provider's appointments today with appointment status completed
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[6]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[6]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[6]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-GetAppointmentTodayCount-8
    [Documentation]  Get provider's appointments today with appointment status cancelled
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-9
    [Documentation]  Get provider's appointments today with appointment status rejected
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Reject Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[5]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[5]}

    ${resp}=  Get Today Appointment Count  apptStatus-eq=${apptStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-10
    [Documentation]  Get provider's appointments today for service ${SERVICE1}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}

    ${resp}=  Get Today Appointment Count  service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-11
    [Documentation]  Get provider's appointments today for consumers with firstname  ${fname2}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   firstName-eq=${fname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}  ${fname2}

    ${resp}=  Get Today Appointment Count  firstName-eq=${fname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-12
    [Documentation]  Get provider's appointments today for consumers with lastname  ${lname1}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}  ${lname1}

    ${resp}=  Get Today Appointment Count  lastName-eq=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-13
    [Documentation]  Get provider's appointments today for encoded id ${encId2}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    # ${DAY3}=  db.add_timezone_date  ${tz}  15  
    # ${DAY4}=  db.add_timezone_date  ${tz}  25    
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-14
    [Documentation]  Get provider's appointments today in schedule ${sch_id1}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    # ${DAY3}=  db.add_timezone_date  ${tz}  15  
    # ${DAY4}=  db.add_timezone_date  ${tz}  25     
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   schedule-eq=${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}  ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['name']}  ${schedule_name1}

    ${resp}=  Get Today Appointment Count  schedule-eq=${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-15
    [Documentation]  Get provider's appointments today where appointment taken by provider (apptBy) and appointment taken by consumer(apptBy) seperately
    ${pid}=  get_acc_id  ${PUSERNAME178}
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today  apptBy-eq=PROVIDER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  apptBy-eq=PROVIDER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Appointments Today  apptBy-eq=CONSUMER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  apptBy-eq=CONSUMER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-16
    [Documentation]  Get provider's appointments today where appointment slot is ${slot1} (apptTime)
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-17
    [Documentation]  Get provider's appointments today where paymentStatus is NotPaid
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    # ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE1}=    FakerLibrary.Word
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}
    clear_customer   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pan_num}=   db.Generate_pan_number
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payuVerify  ${pid}
    Log  ${resp}

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME7}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # # Set Test Variable   ${slot1}   ${Keys[0]}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}  apptStatus=${apptStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}  ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}  ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}  ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}  ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid2}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${min_pre}  ${bool[1]}  ${apptid2}  ${pid}  ${purpose[0]}   ${jdconID}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()['merchantId']}  ${merchantid}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${billable_providers[3]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid2}  ${pid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appt Bill Details   ${apptid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0  
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[1]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetAppointmentTodayCount-18
    [Documentation]  Get provider's appointments today where paymentStatus is PartiallyPaid
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    # ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE1}=    FakerLibrary.Word
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pan_num}=   db.Generate_pan_number
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payuVerify  ${pid}
    Log  ${resp}

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # # Set Test Variable   ${slot1}   ${Keys[0]}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}  apptStatus=${apptStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid2}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${min_pre}  ${bool[1]}  ${apptid2}  ${pid}  ${purpose[0]}   ${jdconID}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200                    
    # Should Be Equal As Strings   ${resp.json()['merchantId']}  ${merchantid}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${billable_providers[3]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid2}  ${pid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appt Bill Details   ${apptid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0 
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

    # Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${apptid2}
    # Should Be Equal As Strings  ${resp.json()[1]['status']}  ${cupnpaymentStatus[0]}  
    # Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  ${pay_mode_selfpay}
    # Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${min_pre} 
    # Should Be Equal As Strings  ${resp.json()[1]['custId']}  ${jdconID}   
    # Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}  ${payment_modes[5]}  
    # Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${pid}    
    # Should Be Equal As Strings  ${resp.json()[1]['paymentGateway']}  RAZORPAY
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  #apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[1]}  appointmentMode=${appointmentMode[2]}  #apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[1]}  appointmentMode=${appointmentMode[2]}  #apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetAppointmentTodayCount-19
    [Documentation]  Get provider's appointments today where paymentStatus is FullyPaid
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    # clear_appt_schedule   ${billable_providers[3]}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}

    ${resp}=  Auto Invoice Generation For Service   ${s_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Auto Invoice Generation For Service   ${s_id2}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid1}  
    ${amount}=  Set Variable  ${resp.json()['amountDue']}  

    ${resp}=  Accept Payment  ${apptid1}  cash  ${amount}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Settl Bill  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    sleep  2s
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[2]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    
    sleep  2s
    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2
    
    sleep  2s
    ${resp}=  Get Appointments Today   paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}  ${fname2}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-20
    [Documentation]  Get provider's appointments today where paymentStatus is Refund
    Log   ${billable_providers}
    ${pro_len}=  Get Length   ${billable_providers}
    clear_service   ${billable_providers[3]}
    clear_location  ${billable_providers[3]}
    ${pid}=  get_acc_id  ${billable_providers[3]}
    # ${cid}=  get_id  ${CUSERNAME15}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE1}=    FakerLibrary.Word
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_appt_schedule   ${billable_providers[3]}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pan_num}=   db.Generate_pan_number
    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  payuVerify  ${pid}
    Log  ${resp}

    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${billable_providers[3]}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    # ${Keys}=  Get Dictionary Keys  ${resp.json()['slot']}
    # # Set Test Variable   ${slot1}   ${Keys[0]}
    # Set Test Variable   ${slot2}   ${Keys[1]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
    ${min_pre}=  Get From Dictionary  ${resp.json()}  _prepaymentAmount

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response             ${resp}     uid=${apptid2}   appmtDate=${DAY1}   appmtTime=${slot2}  apptStatus=${apptStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid2}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock   ${min_pre}  ${bool[1]}  ${apptid2}  ${pid}  ${purpose[0]}   ${jdconID}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()['merchantId']}  ${merchantid}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${billable_providers[3]}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By consumer  ${apptid2}  ${pid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appt Bill Details   ${apptid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0 
    Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

    # Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${apptid2}
    # Should Be Equal As Strings  ${resp.json()[1]['status']}  ${cupnpaymentStatus[0]}  
    # Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  ${pay_mode_selfpay}
    # Should Be Equal As Strings  ${resp.json()[1]['amount']}  ${min_pre} 
    # Should Be Equal As Strings  ${resp.json()[1]['custId']}  ${jdconID}   
    # Should Be Equal As Strings  ${resp.json()[1]['paymentMode']}  ${payment_modes[5]}  
    # Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${pid}    
    # Should Be Equal As Strings  ${resp.json()[1]['paymentGateway']}  RAZORPAY
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}  paymentStatus=${paymentStatus[1]}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    sleep  2s
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...  appointmentEncId=${encId2}  apptStatus=${apptStatus[4]}  paymentStatus=${paymentStatus[3]}

    sleep  2s
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[3]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[4]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   paymentStatus-eq=${paymentStatus[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=CONSUMER   paymentStatus=${paymentStatus[3]}  appointmentMode=${appointmentMode[2]}  apptStatus=${apptStatus[4]}

    ${resp}=  Get Today Appointment Count  paymentStatus-eq=${paymentStatus[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
    

JD-TC-GetAppointmentTodayCount-21
    [Documentation]  Get provider's appointments today in location
    # ${multilocPro}=  MultiLocation
    Log  ${multilocPro}
    ${len}=  Get Length  ${multilocPro}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${multilocPro[3]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${multilocPro[3]}
    clear_location  ${multilocPro[3]}
    # clear_appt_schedule   ${PUSERNAME178}

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
    
    ${lid1}=  Create Sample Location
    ${lid2}=  Create Sample Location
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${multilocPro[3]}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME7}  firstName=${fname1}  lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}  firstName=${fname2}  lastName=${lname2}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid2}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid2}  ${resp.json()[0]['id']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME7}  firstName=${fname1}   lastName=${lname1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid1}   ${resp.json()}

    # ${resp}=  AddCustomer  ${CUSERNAME15}  firstName=${fname2}   lastName=${lname2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid2}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   location-eq=${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid2}

    ${resp}=  Get Today Appointment Count  location-eq=${lid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-22
    [Documentation]  Get provider's appointments today for time apptstartTime
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${s_id1}
    # Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}

    ${resp}=  Get Today Appointment Count  apptstartTime-eq=${slot1_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-GetAppointmentTodayCount-23
    [Documentation]  Get provider's appointments today for jaldeeConsumer
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

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

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${lid}=  Create Sample Location
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  Update Customer Details  ${cid1}  firstName=${fname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}

    ${resp}=  Update Customer Details  ${cid2}  firstName=${fname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${slot1_time}=  Get Substring   ${slot1}  0  5
    ${slot2_time}=  Get Substring   ${slot2}  0  5

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   jaldeeConsumer-eq=${jdconID1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  1
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}

    ${resp}=  Get Today Appointment Count  jaldeeConsumer-eq=${jdconID1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-24
    [Documentation]  Get provider's cancelled appointments today for cancelReason
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason1}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason1}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${num}=  Get Length  ${cancelReason}
    FOR   ${i}  IN RANGE   ${num}
        ${reason2}=  Random Element  ${cancelReason}
        Exit For Loop If  "${reason2}" != "${reason1}"
    END  
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason2}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[4]}

    ${resp}=  Get Today Appointment Count  cancelReason-eq=${reason1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-25
    [Documentation]  Get provider's appointments today for appointmentModes WALK_IN_APPOINTMENT and PHONE_IN_APPOINTMENT
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[0]}  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[1]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  appointmentMode-eq=${appointmentMode[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Appointments Today   appointmentMode-eq=${appointmentMode[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[1]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count  appointmentMode-eq=${appointmentMode[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-26
    [Documentation]  Get provider's appointments today for gender male and female
    @{gens}=  Create List

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob1}   ${resp.json()['userProfile']['dob']}
    Set Test Variable  ${gender1}   ${resp.json()['userProfile']['gender']}
    Append To List   ${gens}   ${resp.json()['userProfile']['gender']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To List   ${gens}   ${resp.json()['userProfile']['gender']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  UpdateCustomer without email  ${cid1}   ${NULL}  ${NULL}  ${NULL}  ${gender1}  ${dob1}  ${NULL}  ${NULL}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${count_male}=  Get Match Count  ${gens}  ${Genderlist[1]}
    ${count_female}=  Get Match Count  ${gens}  ${Genderlist[0]}

    ${resp}=  Get Appointments Today   gender-eq=${Genderlist[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_male}
    # Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['gender']}  ${Genderlist[1]}

    ${resp}=  Get Today Appointment Count  gender-eq=${Genderlist[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_male}

    ${resp}=  Get Appointments Today   gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_female}
    # Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['gender']}  ${Genderlist[0]}

    ${resp}=  Get Today Appointment Count  gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_female}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-27
    [Documentation]  Get provider's appointments today for customers with year of birth ${year}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob1}   ${resp.json()['userProfile']['dob']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Get Consumer By Id  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dob2}   ${resp.json()['userProfile']['dob']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    # clear_appt_schedule   ${PUSERNAME178}

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
    clear_appt_schedule   ${PUSERNAME178}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  Update Customer Details  ${cid1}  dob=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}

    ${resp}=  Update Customer Details  ${cid2}  dob=${dob2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    # ${dob1_year}=  Get Substring   ${dob1}  0  4
    # ${dob2_year}=  Get Substring   ${dob2}  0  4

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=  Get Appointments Today   dob-eq=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['dob']}  ${dob1}

    ${resp}=  Get Today Appointment Count  dob-eq=${dob1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Appointments Today   dob-eq=${dob2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['dob']}  ${dob2}

    ${resp}=  Get Today Appointment Count  dob-eq=${dob2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentTodayCount-28
    [Documentation]  Get provider's appointments today filter by label
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME178}
    clear_location  ${PUSERNAME178}
    clear_appt_schedule   ${PUSERNAME178}

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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname2}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    clear_Label  ${PUSERNAME178}
    ${Values}=  FakerLibrary.Words  	nb=3
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  id=${label_id}  label=${labelname[0]}   displayName=${labelname[1]}  description=${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value1}=   Set Variable   ${ValueSet[${i}]['value']}
    ${resp}=  Add Label for Appointment   ${apptid1}  ${labelname[0]}  ${label_value1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname[0]}=${label_value1}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   uid=${apptid1}   appointmentEncId=${encId1}  label=${label1}

    FOR   ${i}  IN RANGE   ${len-1}
        ${label_value2}=   Set Variable   ${ValueSet[${i}]['value']}
        Exit For Loop If  "${label_value2}" != "${label_value1}"
    END
    ${resp}=  Add Label for Appointment   ${apptid2}  ${labelname[0]}  ${label_value2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label2}=    Create Dictionary  ${labelname[0]}=${label_value2}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   uid=${apptid2}   appointmentEncId=${encId2}  label=${label2}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    Verify Response List   ${resp}  1  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${labelinput}=  Set Variable  ${labelname[0]}::${label_value1}

    ${resp}=  Get Appointments Today   label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  uid=${apptid1}  appointmentEncId=${encId1}  appmtDate=${DAY1}  appmtTime=${slot1}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[0]}  apptStatus=${apptStatus[1]}
    # # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['dob']}  ${dob1}

    ${resp}=  Get Today Appointment Count  label-eq=${labelinput}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetAppointmentTodayCount-UH1
    [Documentation]  Get provider's appointments today without provider login
    
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  

JD-TC-GetAppointmentTodayCount-UH2
    [Documentation]  Get provider's appointments today with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

    ${resp}=  Get Today Appointment Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetAppointmentTodayCount-UH3
    [Documentation]  Get provider's appointments today filtered by account id of another provider
    ${pid}=  get_acc_id  ${PUSERNAME177}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointments Today   account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List   ${resp}  0  uid=${apptid2}  appointmentEncId=${encId2}  appmtDate=${DAY1}  appmtTime=${slot2}  apptBy=PROVIDER   paymentStatus=${paymentStatus[0]}  appointmentMode=${appointmentMode[1]}  apptStatus=${apptStatus[1]}
    # # Should Be Equal As Strings  ${resp.json()[0]['consumer']['userProfile']['dob']}  ${dob2}

    ${resp}=  Get Today Appointment Count  account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1







