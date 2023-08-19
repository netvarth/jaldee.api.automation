*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        NextAvailableTime
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


*** Test Cases ***  
JD-TC-Appointment Schedule NextAvailableTime By Schedule-1
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId
    
    ${resp}=  Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME60}
    clear_location  ${PUSERNAME60} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME60}
    ${DAY1}=  get_date
    Set Suite Variable   ${DAY1}
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
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

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['scheduleName']}                                  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleId']}                                    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['date']}                                          ${DAY1}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}        ${parallel}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['active']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['capacity']}                 ${parallel}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${st}=   timeto24hr   ${sTime1}
    FOR     ${index}  IN RANGE  ${sch_length}
            ${muldur}=  Evaluate   (${index}+1)*${duration}
            ${et12}=  add_two  ${sTime1}  ${muldur}
            ${et}=  timeto24hr  ${et12}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['time']}   ${st}-${et}
        Set Test Variable   ${st}   ${et}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}   ${parallel}
    END

JD-TC-Appointment Schedule NextAvailableTime By Schedule-2
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId with FutureDay
    
    ${resp}=  Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME61}
    clear_location  ${PUSERNAME61} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME61}
    ${DAY1}=  add_date  4
    Set Suite Variable   ${DAY1} 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  ${s_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['scheduleName']}                                  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleId']}                                    ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['date']}                                          ${DAY1}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}        ${parallel}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['active']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['capacity']}                 ${parallel}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${st}=   timeto24hr   ${sTime1}
    FOR     ${index}  IN RANGE  ${sch_length}
            ${muldur}=  Evaluate   (${index}+1)*${duration}
            ${et12}=  add_two  ${sTime1}  ${muldur}
            ${et}=  timeto24hr  ${et12}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['time']}   ${st}-${et}
        Set Test Variable   ${st}   ${et}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}   ${parallel}
    END

JD-TC-Appointment Schedule NextAvailableTime By Schedule-3
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId with Holiday
    
    ${resp}=  Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME62}
    clear_location  ${PUSERNAME62} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    clear_appt_schedule   ${PUSERNAME62}
    ${DAY1}=  get_date
    Set Suite Variable   ${DAY1}
    ${DAY2}=  add_date  10 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  ${s_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    # ${resp}=  Create Holiday   ${DAY1}  ${desc}  ${sTime1}  ${eTime1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['scheduleName']}                                  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleId']}                                    ${sch_id3}
    Should Be Equal As Strings  ${resp.json()['date']}                                          ${DAY1}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}        0
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['active']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['availableSlots'][0]['capacity']}                 ${parallel}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${st}=   timeto24hr   ${sTime1}
    FOR     ${index}  IN RANGE  ${sch_length}
            ${muldur}=  Evaluate   (${index}+1)*${duration}
            ${et12}=  add_two  ${sTime1}  ${muldur}
            ${et}=  timeto24hr  ${et12}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['time']}   ${st}-${et}
        Set Test Variable   ${st}   ${et}
        Should Be Equal As Strings   ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']}   0
    END

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH1
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId with Another Provider
    
    ${resp}=  Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}"   

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH2
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId with Another ScheduleId
    
    ${resp}=  Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_PERMISSION}" 

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH3
    [Documentation]   Appointment Schedyle NextAvailbleTime By ScheduleId is Zero
    
    ${resp}=  Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"     "${SHEDULE_NOT_FOUND}"
    

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH4
    [Documentation]   Without Provider Login

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH5
    [Documentation]   With another Provider Login
    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"       "${NO_PERMISSION}"

JD-TC-Appointment Schedule NextAvailableTime By Schedule-UH6
    [Documentation]   With Consumer Login
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get AppmtSchedule NextAvailableTime By ScheduleId    ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"