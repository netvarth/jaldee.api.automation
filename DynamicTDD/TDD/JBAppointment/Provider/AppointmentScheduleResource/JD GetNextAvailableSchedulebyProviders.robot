*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        NextAvailableSchedule
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
${SERVICE1}     Consultation 
${SERVICE2}     Scanning
${SERVICE3}     Scannings111
${pid5}          0


*** Test Cases ***  
JD-TC-NextAvailableSchedule By Providers-1
    [Documentation]   Appointment Schedyle NextAvailbleSchedule By Providers with single Schedule
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME110}
    Set Suite Variable   ${pid}
    clear_service   ${PUSERNAME110}
    clear_location  ${PUSERNAME110} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME110}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  ${s_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid}   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                                                 ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}                            ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}                                 ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}                         ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][1]['id']}                         ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}                              ${duration}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}                           ${parallel}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}                               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}                                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}                             ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}                                               ${bool[1]}
    
 
JD-TC-NextAvailableSchedule By Providers-2
    [Documentation]   NextAvailbleSchedule By Providers with Appointment is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME111}

    clear_service   ${PUSERNAME111}
    clear_location  ${PUSERNAME111} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    ${resp}=   Disable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  1s
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    sleep   01s
    
    ${lid1}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME111}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['message']}            ${APPT_NOT_ENABLED}                               
    
    ${resp}=   Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule By Providers-3
    [Documentation]   NextAvailbleSchedule By Providers with Location is not Found
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME110}

    clear_service   ${PUSERNAME110}
    clear_location  ${PUSERNAME110} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid}   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['message']}            ${LOCATION_NOT_FOUND}                               

JD-TC-NextAvailableSchedule By Providers-4
    [Documentation]   NextAvailbleSchedule By Providers with TodayAppmt is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME111}

    clear_service   ${PUSERNAME111}
    clear_location  ${PUSERNAME111} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 
    
    ${lid1}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME111}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=   Disable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 

    sleep  01s

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[0]}   futureAppt=${bool[1]}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}                                 ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}                                ${bool[1]}

    ${resp}=   Enable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-NextAvailableSchedule By Providers-5
    [Documentation]   NextAvailbleSchedule By Providers when FutureAppt is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME111}

    clear_service   ${PUSERNAME111}
    clear_location  ${PUSERNAME111} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 
    
    ${lid1}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME111}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=   Disable Future Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[0]} 

    sleep  01s

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[0]}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}                            ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}                                ${bool[0]}

    ${resp}=   Enable Future Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule By Providers-6
    [Documentation]   NextAvailbleSchedule By Providers with Available Now
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME111}
    Set Suite Variable    ${pid1}

    clear_service   ${PUSERNAME111}
    clear_location  ${PUSERNAME111} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 
    ${resp1}=   Run Keyword If   '${resp.json()['futureAppt']}' == '${bool[0]}'   Enable Future Appointment
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${lid1}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}

    clear_appt_schedule   ${PUSERNAME111}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  60  
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${resp}=    Get Appmt Schedule AvailableNow
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}    locationId=${lid1}    availableNow=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['timeRange']['sTime']}        ${sTime1}
    Should Be Equal As Strings  ${resp.json()['timeRange']['eTime']}        ${eTime1}
   
    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}                            ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}                                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}                                   ${bool[1]}

JD-TC-NextAvailableSchedule By Providers-7
    [Documentation]   NextAvailbleSchedule By Providers with AccountId is Zero
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME111}
    clear_location  ${PUSERNAME111} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 
    
    ${lid1}=  Create Sample Location
    Set Suite Variable   ${lid1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}

    clear_appt_schedule   ${PUSERNAME111}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10     
    Set Suite Variable   ${DAY2}   
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  60  
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}
    
    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid5}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid5}
    Should Be Equal As Strings  ${resp.json()[0]['message']}            ${ACCOUNT_NOT_EXIST}

# ***Comments***
JD-TC-NextAvailableSchedule By Providers-8
    [Documentation]   With Another Provider Login
    
    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}     ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}   ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}   ${bool[1]}
    

JD-TC-NextAvailableSchedule By Providers-9
    [Documentation]   With Consumer Login
    
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}   ${bool[1]}

JD-TC-NextAvailableSchedule By Providers-10
    [Documentation]   Without Provider Login

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}   ${bool[1]}

JD-TC-NextAvailableSchedule By Providers-UH1
    [Documentation]   with invalid account id
    
    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${randint}=    Generate Random String    length=4    chars=[NUMBERS]
    ${randint}=    Convert To Integer    ${randint}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${randint}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${randint}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ACCOUNT_NOT_EXIST}

JD-TC-NextAvailableSchedule By Providers-UH2
    [Documentation]   with invalid location id
    
    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${randint}=    Generate Random String    length=4    chars=[NUMBERS]
    ${randint}=    Convert To Integer    ${randint}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${randint}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${LOCATION_NOT_FOUND}

JD-TC-NextAvailableSchedule By Providers-UH3
    [Documentation]   when appointment is disabled
    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=   Disable Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    sleep  01s

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${APPT_NOT_ENABLED}

    ${resp}=  Enable Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

JD-TC-NextAvailableSchedule By Providers-UH4
    [Documentation]   when today appointment is disabled

    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=  Disable Today Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[0]}

    sleep  01s

    ${DAY3}=   db.add_timezone_date  ${tz}  1  

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}     ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}   ${bool[1]}

    ${resp}=  Enable Today Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

JD-TC-NextAvailableSchedule By Providers-UH5
    [Documentation]   when schedule is disabled

    ${pid1}=  get_acc_id  ${PUSERNAME111}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Disable Appointment Schedule  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[1]}

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ONLINE_APPT_NOT_AVAILABLE}

    ${resp}=  Enable Appointment Schedule  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

JD-TC-NextAvailableSchedule By Providers-UH6
    [Documentation]   when location is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME110}
    clear_service   ${PUSERNAME110}
    clear_location  ${PUSERNAME110} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME110}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    # ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid}   ${lid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  status=ACTIVE

    ${resp}=  Disable Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  status=INACTIVE

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${LOCATION_NOT_FOUND}

    ${resp}=  Enable Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  status=ACTIVE

JD-TC-NextAvailableSchedule By Providers-UH7
    [Documentation]   when start date and end date is same day and today appointment is disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME110}
    clear_service   ${PUSERNAME110}
    clear_location  ${PUSERNAME110} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    clear_appt_schedule   ${PUSERNAME110}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    # ${resp}=   Get Appointment Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=  Disable Today Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[0]}

    # ${DAY3}=   db.add_timezone_date  ${tz}  1  
    sleep   01s

    ${resp}=    Get NextAvailableSchedule By Provider Location    ${pid1}   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}     ${pid1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}     ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}   ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']  ${DAY3}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['openNow']}   ${bool[0]}

    ${resp}=  Enable Today Appointment
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}