*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Schedule Delay
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


*** Variables ***
${SERVICE1}     Consultation
${SERVICE2}     AvailableNow 
${self}         0
${count}        0

*** Test Cases ***  


JD-TC-Appointment Schedule Delay By Scheduleid-1
    [Documentation]    Add Delay time Send message and verifying sent notifications to Different consumers    
    
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID2}   ${resp.json()['id']}
    Set Suite Variable  ${fname2}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname2}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname2}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${accountId}  ${decrypted_data['id']}
    Set Suite Variable   ${Pf_name}   ${decrypted_data['firstName']}
    # Set Suite Variable   ${accountId}   ${resp.json()['id']}
    # Set Suite Variable   ${Pf_name}   ${resp.json()['firstName']}
    ${pid}=  get_acc_id  ${PUSERNAME61}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname61}  ${resp.json()['businessName']}

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

    clear_service   ${PUSERNAME61}
    clear_location  ${PUSERNAME61}
    clear_appt_schedule   ${PUSERNAME61}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location By Id   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   0  90
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=20
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                    200
    Verify Response  ${resp}     delayDuration=0

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME2}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    clear_Consumermsg  ${CUSERNAME2}

    ${apptfor}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor}
    Set Suite Variable   ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}

    clear_Consumermsg  ${CUSERNAME3}

    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot1}
    ${apptfor3}=   Create List  ${apptfor2}
    Set Suite Variable   ${apptfor3}

    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${apptid2_time}   ${resp.json()[0]['appmtTime']}
    Set Suite Variable   ${apptid3_time}   ${resp.json()[1]['appmtTime']}
    Set Suite Variable   ${consumer_id}   ${resp.json()[1]['consumer']['id']}
    Set Suite Variable   ${conf_name}   ${resp.json()[1]['consumer']['userProfile']['firstName']}
    Set Suite Variable   ${consumer_id1}   ${resp.json()[0]['consumer']['id']}
    Set Suite Variable   ${conf_name1}   ${resp.json()[0]['consumer']['userProfile']['firstName']}


    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}


    ${resp}=  AddCustomer  ${CUSERNAME4}  firstName=${fname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()}
    clear_Consumermsg  ${CUSERNAME4}

    ${apptfor4}=  Create Dictionary  id=${cid3}   apptTime=${slot1}
    ${apptfor5}=   Create List  ${apptfor4}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid3}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId3}=  Set Variable   ${resp.json()}

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${consumer_id3}   ${resp.json()[2]['consumer']['id']}
    Set Suite Variable   ${conf_name3}   ${resp.json()[2]['consumer']['userProfile']['firstName']}

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defapptDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rcid2}  ${resp.json()['id']}         
    Set Suite Variable  ${consumername3}  ${resp.json()['userName']}

    ${bookingid}=  Format String  ${bookinglink}  ${encId2}  ${encId2}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname1}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId2}

    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname1}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId2}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins

    sleep  2s

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Verify Response List  ${resp}  0  waitlistId=${apptid2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${defconfirm_msg}
    # Verify Response List  ${resp}  1  waitlistId=${apptid2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${consumer_id}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rcid3}  ${resp.json()['id']}
    Set Suite Variable  ${consumername4}  ${resp.json()['userName']}

    ${bookingid}=  Format String  ${bookinglink}  ${encId3}  ${encId3}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname2}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId3}
    
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname2}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId3}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    # ${msg}=  Replace String  ${msg}  [delaytime]   ${mins}${SPACE}mins


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  1  waitlistId=${apptid3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${consumer_id3}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname2}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Appointment Schedule Delay By Scheduleid-2
    [Documentation]  Add delay time and Send notifications to consumers when online Presence is Disable  

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID3}   ${resp.json()['id']}
    Set Suite Variable  ${fname3}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname3}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME61}
    clear_location  ${PUSERNAME61}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME61}
    clear_consumer_msgs  ${CUSERNAME5}
    clear_provider_msgs  ${PUSERNAME61}
    ${pid2}=  get_acc_id  ${PUSERNAME61}
    Set Suite Variable   ${pid2}

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

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[0]}  ${boolean[1]}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}  
    
    ${SERVICE1}=    FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME61}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}   1  40
    ${eTime1}=  add_timezone_time  ${tz}   2  10
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=20
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=    Get Appointment Schedule Delay    ${sch_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                    200
    Verify Response  ${resp}     delayDuration=0

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
    Set Suite Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid4}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME5}  firstName=${fname3}   lastName=${lname3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}   ${resp.json()}
    
    ${apptfor}=  Create Dictionary  id=${cid4}   apptTime=${slot2}
    ${apptfor2}=   Create List  ${apptfor}
    Set Suite Variable   ${apptfor2}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid4}  ${s_id}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Appointment Schedule Delay  ${sch_id2}  ${delay_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response  ${resp}     delayDuration=${delay_time}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{emptylist}=  Create List
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}   ${emptylist}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Appointment Schedule Delay By Scheduleid-3
    [Documentation]   Add delay time and Send notifications to consumers when online Presence is Enable
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID4}   ${resp.json()['id']}
    Set Suite Variable  ${fname4}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname4}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname4}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${accountId}  ${decrypted_data['id']}
    Set Suite Variable   ${Pf_name}   ${decrypted_data['firstName']}
    # Set Suite Variable   ${accountId}   ${resp.json()['id']}
    # Set Suite Variable   ${Pf_name}   ${resp.json()['firstName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname69}  ${resp.json()['businessName']}

    clear_service   ${PUSERNAME69}
    # clear_service   ${PUSERNAME69}
    clear_location  ${PUSERNAME69}
    clear_consumer_msgs  ${CUSERNAME17}
    clear_provider_msgs  ${PUSERNAME69}
    

    ${pid3}=  get_acc_id  ${PUSERNAME69}
    Set Suite Variable   ${pid3}

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
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME69}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    # clear_appt_schedule   ${PUSERNAME69}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   0  90
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=20
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                    200
    Verify Response  ${resp}     delayDuration=0

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}  

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid5}  ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME17}  firstName=${fname4}   lastName=${lname4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid5}   ${resp.json()}

    ${apptfor}=  Create Dictionary  id=${cid5}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor}
    Set Suite Variable   ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid5}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${apptid4_time}   ${resp.json()[0]['appmtTime']}
    Set Suite Variable   ${consumer_id4}   ${resp.json()[0]['consumer']['id']}
    Set Suite Variable   ${conf_name4}   ${resp.json()[0]['consumer']['userProfile']['firstName']}

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

    # ${resp}=  Get Appointment Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defapptDelayAdd_msg}=  Set Variable   ${resp.json()['apptDelayAdd_push']}
    # ${defconfirm_msg}=  Set Variable   ${resp.json()['confirmAppt_push']} 

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defapptDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    Set Suite Variable  ${rcid4}  ${resp.json()['id']}

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [username]   ${consumername} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname69}

    ${bookingid}=  Format String  ${bookinglink}  ${encId1}  ${encId1}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname4}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId1}

    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname4}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId1}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${desc}=    FakerLibrary.sentence
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    # ${apptid4_converted_slot}=  convert_slot_12hr  ${apptid4_time}
    # ${msg}=  Replace String    ${defapptDelayAdd_msg}  [provider name]   ${bsname69}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE1}
    # ${msg}=  Replace String  ${msg}  [delay time in hrs and mts]  ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    # ${msg}=  Replace String  ${msg}  [time]     ${apptid4_converted_slot}
    # ${msg}=  Replace String  ${msg}  [date]     ${date}

    # ${inverse_date}=  Convert Date  ${DAY1}  result_format=%Y-%m-%d

    # Log  ${msg}

    # Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE1} on ${date}  accountId=${pid3}  msg=${defconfirm_msg}
    # Verify Response List  ${resp}  1  waitlistId=${apptid1}  service=${SERVICE1} on ${date}  accountId=${pid3}  msg=${msg}
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
    # # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${Pf_name}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${consumer_id4}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${uname4}


JD-TC-Appointment Schedule Delay By Scheduleid-4
    [Documentation]   When delay is Zero
    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${delay_time}=   Random Int  min=1   max=60
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

    
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DELAY_DURATION}"

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}


JD-TC-Appointment Schedule Delay By Scheduleid-5
    [Documentation]    Add delay after disabling Appointment
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40123
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME}${\n}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME60}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    ${delay_time}=   Random Int  min=10   max=30
    Set Suite Variable   ${delay_time}
    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

    ${resp}=   Enable Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}


JD-TC-Appointment Schedule Delay By Scheduleid-6
    [Documentation]    Add delay after disabling Appointment Location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${accountId}  ${decrypted_data['id']}
    Set Suite Variable   ${Pf_name}   ${decrypted_data['firstName']}
    # Set Suite Variable   ${accountId}   ${resp.json()['id']}
    # Set Suite Variable   ${Pf_name}   ${resp.json()['firstName']}
    ${pid}=  get_acc_id  ${PUSERNAME1}

    clear_service   ${PUSERNAME1}
    clear_location  ${PUSERNAME1}
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${lid2}=  Create Sample Location
    Set Suite Variable   ${lid2}

    ${resp}=   Get Location By Id   ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   0  90
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}                    200
    Verify Response  ${resp}     delayDuration=0

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Disable Location  ${lid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${delay_time}=   Random Int  min=10   max=30
    Set Suite Variable   ${delay_time}
    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time}

JD-TC-Appointment Schedule Delay By Scheduleid-7
    [Documentation]   Applying More Add delay times and verifying notification messages for one particular consumer
    
    ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID5}   ${resp.json()['id']}
    Set Suite Variable  ${fname5}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname5}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname5}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_Consumermsg  ${CUSERNAME22}
    # clear_Consumermsg  ${CUSERNAME3}
    @{dom_list}=  Create List
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    ${domlen}=  Get Length   ${multilocdoms}
    FOR   ${i}  IN RANGE   ${domlen}
        ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
        Append To List   ${dom_list}  ${dom}
    END
    Log   ${dom_list}
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${b}  IN RANGE   ${length}    
        ${resp1}=  Encrypted Provider Login  ${PUSERNAME${b}}  ${PASSWORD}
        # Log   ${resp1.json()}
        Should Be Equal As Strings    ${resp1.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp1.content}
        Log  ${decrypted_data}

        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp1.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp1.json()['subSector']}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
        Log Many  ${status} 	${value}
        ${count}=   Run Keyword If   '${status}' == 'PASS'  Evaluate  ${count}+1
        ...         ELSE  Set Variable   ${count}
        Exit For Loop If  '${status}' == 'PASS' and '${count}' == '2'
    END
    Set Suite Variable   ${b}
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
    
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${accountId}   ${decrypted_data['id']}
    Set Suite Variable   ${Pf_name}   ${decrypted_data['firstName']}
    ${pid2}=    get_acc_id   ${PUSERNAME${b}}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}

    ${lid}=     Create Sample Location

    ${resp}=   Get Location By Id   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${SERVICE2}=    FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    clear_appt_schedule   ${PUSERNAME${b}}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  60  
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=6  max=20
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
      
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}   ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}  

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid8}  ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME22}  firstName=${fname5}   lastName=${lname5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid8}   ${resp.json()}

    ${apptfor}=  Create Dictionary  id=${cid8}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor}
    Set Suite Variable   ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid8}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${apptid4_time}   ${resp.json()[0]['appmtTime']}
    Set Suite Variable   ${consumer_id4}   ${resp.json()[0]['consumer']['id']}
    Set Suite Variable   ${conf_name4}   ${resp.json()[0]['consumer']['userProfile']['firstName']}

    ${delay_time}=   Random Int  min=10   max=30
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response  ${resp}     delayDuration=${delay_time}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defapptDelayAdd_msg}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  ConsumerLogin  ${CUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    Set Suite Variable  ${rcid4}  ${resp.json()['id']}

    
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [username]   ${consumername} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE2}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

    ${bookingid}=  Format String  ${bookinglink}  ${encId1}  ${encId1}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname5}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId1}
    
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname5}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId1}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${desc}=    FakerLibrary.sentence
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    # ${apptid4_converted_slot}=  convert_slot_12hr  ${apptid4_time}
    # ${msg}=  Replace String    ${defapptDelayAdd_msg}  [provider name]   ${bsname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE2}
    # ${msg}=  Replace String  ${msg}  [delay time in hrs and mts]  ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    # ${msg}=  Replace String  ${msg}  [time]     ${apptid4_converted_slot}
    # ${msg}=  Replace String  ${msg}  [date]     ${date}
    # Log  ${msg}


    Verify Response List  ${resp}  0  waitlistId=${apptid1}  service=${SERVICE2} on ${date}  accountId=${pid2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${Pf_name}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${consumer_id4}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}  ${uname5}

    Verify Response List  ${resp}  1  waitlistId=${apptid1}  service=${SERVICE2} on ${date}  accountId=${pid2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[1]['owner']['name']}  ${Pf_name}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${consumer_id4}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${uname5}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME${b}}    ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    #updateIncreasingAddDelayTime
    comment   updateIncreasingAddDelayTime
    ${des}=   FakerLibrary.sentence
    ${delay_time2}=    Random Int  min=30    max=60
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${delay_time2}

    ${resp}=  ConsumerLogin  ${CUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    Set Suite Variable  ${rcid4}  ${resp.json()['id']}

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time2}

    ${bookingid}=  Format String  ${bookinglink}  ${encId1}  ${encId1}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname5}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId1}
    
    # ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time2}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname5}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId1}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${desc}=    FakerLibrary.sentence
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time2}
    # ${apptid4_converted_slot}=  convert_slot_12hr  ${apptid4_time}
    # ${msg}=  Replace String    ${defapptDelayAdd_msg}  [provider name]   ${bsname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE2}
    # ${msg}=  Replace String  ${msg}  [delay time in hrs and mts]  ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    # ${msg}=  Replace String  ${msg}  [time]     ${apptid4_converted_slot}
    # ${msg}=  Replace String  ${msg}  [date]     ${date}
    # Log  ${msg}


    # Verify Response List  ${resp}  2  waitlistId=${apptid1}  service=${SERVICE2} on ${date}  accountId=${pid2}
    # Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}  0
    # # Should Be Equal As Strings  ${resp.json()[1]['owner']['name']}  ${Pf_name}
    # Should Be Equal As Strings  ${resp.json()[2]['msg']}   ${msg}
    # Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}  ${consumer_id4}
    # Should Be Equal As Strings  ${resp.json()[2]['receiver']['name']}  ${consumername}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME${b}}    ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    #UpdateWithDecresingAddDelayTime
    comment   UpdateWithDecresingAddDelayTime
    ${des}=   FakerLibrary.sentence
    ${delay_time3}=    Random Int  min=1    max=${delay_time2}
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response  ${resp}     delayDuration=${delay_time3}

    ${resp}=  ConsumerLogin  ${CUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    Set Suite Variable  ${rcid4}  ${resp.json()['id']}

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time3}

    ${bookingid}=  Format String  ${bookinglink}  ${encId1}  ${encId1}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname5}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId1}
    
    # ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time3}
    ${msg}=  Replace String  ${defapptDelayAdd_msg}  [consumer]   ${uname5}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId1}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[1]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
   
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${desc}=    FakerLibrary.sentence
    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${delay_time}=   Convert To String  ${delay_time3}
    # ${apptid4_converted_slot}=  convert_slot_12hr  ${apptid4_time}
    # ${msg}=  Replace String    ${delayappmt}  [username]  ${consumername}
    # ${msg}=  Replace String  ${msg}  [apptid_time]  ${apptid4_converted_slot}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE2}
    # ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
    # ${msg}=  Replace String  ${msg}  [time]     0
    # ${msg}=  Replace String  ${msg}  [date]     ${DAY1}
    
    Log  ${msg}

    # Verify Response List  ${resp}  3  waitlistId=${apptid1}  service=${SERVICE2} on ${date}  accountId=${pid2}
    # Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}  0
    # # Should Be Equal As Strings  ${resp.json()[2]['owner']['name']}  ${Pf_name}
    # Should Be Equal As Strings  ${resp.json()[3]['msg']}   ${msg}
    # Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}  ${consumer_id4}
    # Should Be Equal As Strings  ${resp.json()[3]['receiver']['name']}  ${consumername}


JD-TC-Appointment Schedule Delay By Scheduleid-UH1
    [Documentation]   Add delay using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${delay_time}=   Random Int  min=10   max=30
    Set Suite Variable   ${delay_time}
    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Appointment Schedule Delay By Scheduleid-UH2
    [Documentation]    Add delay without Provider login
    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Appointment Schedule Delay By Scheduleid-UH3
    [Documentation]   Add delay to another provider's Appointment
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Appointment Schedule Delay By Scheduleid-UH4
    [Documentation]    Add Delay performing after business hours
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME80}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}

    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${sTime1}=  add_timezone_time  ${tz}  0  10  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${eTime1}


    ${schedule_name14}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name14}
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=5
    Set Suite Variable   ${duration} 
    
    ${resp}=  Create Appointment Schedule  ${schedule_name14}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id14}  ${resp.json()}

    ${delay_time4}=   Random Int  min=30   max=40
    Set Suite Variable   ${delay_time4}

    ${des}=   FakerLibrary.sentence
    ${resp}=  Add Appointment Schedule Delay  ${sch_id14}  ${delay_time4}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_DELAY_CANT_APPLY}"

    ${resp}=    Get Appointment Schedule Delay    ${sch_id14}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=${duration}

