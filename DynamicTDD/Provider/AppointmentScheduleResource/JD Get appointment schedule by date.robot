*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Appointment, Schedule
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}  manicure 
${SERVICE2}  pedicure

*** Test Cases ***
JD-TC-Get schedule By Date-1
    [Documentation]  Get schedule for today's date
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule by date  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name}  id=${sch_id} 
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime1}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=1  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    ${lid1}=  Create Sample Location
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule by date  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  name=${schedule_name1}  id=${sch_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()[1]['services'][0]['id']}  ${s_id}

JD-TC-Get schedule By Date-2
    [Documentation]  Get schedule for future date
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${DAY3}=  add_date  5
    ${DAY4}=  add_date  15      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule by date  ${DAY3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name}  id=${sch_id} 
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}

    ${schedule_name1}=  FakerLibrary.bs
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime1}  ${delta1}
    ${converted_eTime2}=  db.convert_time   ${eTime2}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration1}=  FakerLibrary.Random Int  min=1  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    ${lid1}=  Create Sample Location
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule by date  ${DAY3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name}  id=${sch_id}
    Verify Response List  ${resp}  1  name=${schedule_name1}  id=${sch_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['startDate']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['terminator']['endDate']}  ${DAY4}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()[1]['services'][0]['id']}  ${s_id}

JD-TC-Get schedule By Date-3
    [Documentation]  Get schedule for past date
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${DAY3}=  subtract_date  5
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule by date  ${DAY3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get schedule By Date-4
    [Documentation]  Get schedule for End date
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule by date  ${DAY2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name}  id=${sch_id} 
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}

JD-TC-Get schedule By Date-5
    [Documentation]  Get schedule for a future date outside start and end date
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10   
    ${DAY3}=  add_date  15  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule by date  ${DAY3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get schedule By Date-UH1
    [Documentation]  Get schedule by date without login
    ${resp}=  Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME183}
    clear_location  ${PUSERNAME183}
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment Schedule by date  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
