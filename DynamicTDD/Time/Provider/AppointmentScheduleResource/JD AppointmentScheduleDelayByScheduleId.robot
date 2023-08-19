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

*** Test Cases ***  
JD-TC-Appointment Schedule Delay By Scheduleid-1
    [Documentation]    Appointment Schedule Delay By ScheduleId with a valid Provider
    
    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID1}   ${resp.json()['id']}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}
    Set Test Variable  ${uname1}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID2}   ${resp.json()['id']}
    Set Test Variable  ${fname2}   ${resp.json()['firstName']}
    Set Test Variable  ${lname2}   ${resp.json()['lastName']}
    Set Test Variable  ${uname2}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID3}   ${resp.json()['id']}
    Set Test Variable  ${fname3}   ${resp.json()['firstName']}
    Set Test Variable  ${lname3}   ${resp.json()['lastName']}
    Set Test Variable  ${uname3}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID4}   ${resp.json()['id']}
    Set Test Variable  ${fname4}   ${resp.json()['firstName']}
    Set Test Variable  ${lname4}   ${resp.json()['lastName']}
    Set Test Variable  ${uname4}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${accountId}   ${resp.json()['id']}
    Set Suite Variable   ${Pf_name}   ${resp.json()['firstName']}
    ${pid}=  get_acc_id  ${PUSERNAME60}

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

    clear_service   ${PUSERNAME60}
    clear_location  ${PUSERNAME60}
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME60}
    ${DAY1}=  get_date
    Set Suite Variable   ${DAY1}
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${eTime1}=  add_time   0  90
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

    ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname1}   lastName=${lname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}   ${resp.json()[0]['id']}
    
    ${apptfor}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor1}=   Create List  ${apptfor}
    
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

    ${resp}=  AddCustomer  ${CUSERNAME13}  firstName=${fname2}   lastName=${lname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot1}
    ${apptfor3}=   Create List  ${apptfor2}
    
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
    # Set Suite Variable   ${consumer_id}   ${resp.json()[1]['consumer']['id']}
    # Set Suite Variable   ${conf_name}   ${resp.json()[1]['consumer']['userProfile']['firstName']}
    # Set Suite Variable   ${consumer_id1}   ${resp.json()[0]['consumer']['id']}
    # Set Suite Variable   ${conf_name1}   ${resp.json()[0]['consumer']['userProfile']['firstName']}

    clear_Consumermsg  ${CUSERNAME12}
    clear_Consumermsg  ${CUSERNAME13}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}

    ${resp}=  AddCustomer  ${CUSERNAME14}  firstName=${fname3}   lastName=${lname3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}   ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid3}   ${resp.json()[0]['id']}
    
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

    clear_Consumermsg  ${CUSERNAME14}

    ${delay_time}=   Random Int  min=10   max=40
    ${resp}=  Add Appointment Schedule Delay  ${sch_id}  ${delay_time}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response  ${resp}     delayDuration=${delay_time}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}  ${resp.json()['businessName']}
    ${resp}=    Get Appointments Today
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # Set Suite Variable   ${consumer_id2}   ${resp.json()[2]['consumer']['id']}
    # Set Suite Variable   ${conf_name2}   ${resp.json()[2]['consumer']['userProfile']['firstName']}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${appmtdelay}=  Set Variable   ${resp.json()['delayMessages']['Consumer_APP']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200    

    sleep  05s
    
    ${resp}=  ConsumerLogin  ${CUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}

    ${date}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}

    ${bookingid}=  Format String  ${bookinglink}  ${encId1}  ${encId2}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname2}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId2}
    
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${appmtdelay}  [consumer]   ${uname2}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId2}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins
    
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Log  ${msg}

    Run Keyword IF  '${len}' == '1'
    ...    Run Keywords 
    ...    Verify Response List  ${resp}  0  waitlistId=${apptid2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            ${accountId}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${jdconID2}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname2}
    ...    ELSE  
    ...    Run Keywords 
    ...    Verify Response List  ${resp}  0  waitlistId=${apptid2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${defconfirm_msg} 
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            ${accountId}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${jdconID2}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname2}  
    ...    AND  Verify Response List  ${resp}  1  waitlistId=${apptid2}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  05s
    ${resp}=  ConsumerLogin  ${CUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    #Set Suite Variable  ${consumername}  ${resp.json()['userName']}

    ${bookingid}=  Format String  ${bookinglink}  ${encId3}  ${encId3}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname3}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId3}
    
    ${hrs}  ${mins}=   convert_hour_minutes   ${delay_time}
    ${msg}=  Replace String  ${appmtdelay}  [consumer]   ${uname3}
    ${msg}=  Replace String  ${msg}  [bookingId]   ${encId3}
    ${msg}=  Replace String  ${msg}  [delayType]   ${delayType[0]}
    ${msg}=  Replace String  ${msg}  [delaytime]   ${hrs}${SPACE}hrs${SPACE}${mins}${SPACE}mins

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Log  ${msg}

    Run Keyword IF  '${len}' == '1'
    ...    Run Keywords 
    ...    Verify Response List  ${resp}  0  waitlistId=${apptid3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg} 
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            ${accountId}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${jdconID3}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname3}
    ...    ELSE  
    ...    Run Keywords 
    ...    Verify Response List  ${resp}  0  waitlistId=${apptid3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${defconfirm_msg} 
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            ${accountId}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}            0
    # ...    AND  Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}          ${Pf_name} 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}         ${jdconID3}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}       ${uname3}  
    ...    AND  Verify Response List  ${resp}  1  waitlistId=${apptid3}  service=${SERVICE1} on ${date}  accountId=${pid}  msg=${msg}
    

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    change_system_time  0  5
    ${new_delay_time}=  Evaluate  ${delay_time}-5

    ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response  ${resp}     delayDuration=${new_delay_time}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${apptid2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${apptid3}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}

    sleep  02s

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${apptid3}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}

    ${new_delay_time1}=  Evaluate  ${new_delay_time}+5
    ${resp}=  AddCustomer  ${CUSERNAME15}  firstName=${fname4}   lastName=${lname4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid4}   ${resp.json()[0]['id']}
    
    ${apptfor6}=  Create Dictionary  id=${cid4}   apptTime=${slot1}
    ${apptfor7}=   Create List  ${apptfor6}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid4}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}           ${apptid4}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}

    clear_Consumermsg  ${CUSERNAME14}
    clear_Consumermsg  ${CUSERNAME15}

    # ${resp}=  Add Appointment Schedule Delay  ${sch_id}   0
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Appointment Schedule Delay    ${sch_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200
    # Verify Response  ${resp}     delayDuration=0
    # sleep  05s

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}

    ${resp}=  Get Appointment By Id   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid4}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}    ${apptStatus[2]}