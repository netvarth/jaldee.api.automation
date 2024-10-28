*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{service_names}

*** Test Cases ***  

JD-TC-NextAvailableSchedule for User-1

    [Documentation]   Get next available schedule for user when there is only one schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME340}

    # clear_service   ${PUSERNAME340}
    # clear_appt_schedule   ${PUSERNAME340}
  
    ${PUSERPH0}  ${u_id} =  Create and Configure Sample User
    Set Suite Variable  ${PUSERPH0}
    Set Suite Variable  ${u_id}

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}    provider=${u_id}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule    ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                                                 ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}                                        ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}                            ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}                                 ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}                         ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}                              ${duration}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}                           ${parallel}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}                                 ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}                                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}                             ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}                                               ${bool[1]}
    Should Contain  "${resp.json()}"  availableSlots

JD-TC-NextAvailableSchedule for User-2

    [Documentation]   Get next available schedule for user when there are more than 1 schedule

    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME340}

    # clear_service   ${PUSERNAME340}
    # clear_appt_schedule   ${PUSERNAME340}
    # clear_service   ${PUSERPH0}
    # clear_appt_schedule   ${PUSERPH0}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}    provider=${u_id}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  5  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  add_two  ${eTime1}  5
    ${delta2}=  FakerLibrary.Random Int  min=40  max=80
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/5}
    ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule    ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${parallel2}  ${lid}  ${duration2}  ${bool2}  ${s_id}   provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}
    
    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()}"  availableSlots
    ${sch_length}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}

JD-TC-NextAvailableSchedule for User-3

    [Documentation]   Get next available schedule for user when there are more than 1 schedule and one schedule timings are over

    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME340}

    # clear_service   ${PUSERNAME340}
    # clear_appt_schedule   ${PUSERNAME340}
    # clear_service   ${PUSERPH0}
    # clear_appt_schedule   ${PUSERPH0}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service   ${SERVICE1}   provider=${u_id}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${time_now}=   db.get_time_by_timezone  ${tz}
    ${sTime1}=  sub_two  ${time_now}   ${delta1+5}
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}      ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}   provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta2}=  FakerLibrary.Random Int  min=40  max=80
    ${sTime2}=  add_timezone_time  ${tz}  0  5  
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/5}
    ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${parallel2}  ${lid}  ${duration2}  ${bool2}  ${s_id}   provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}  ${schedule_name2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    # Should Contain  "${resp.json()}"  availableSlots
    # ${sch_length}=  get_slot_length  ${delta2}  ${duration2}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}

JD-TC-NextAvailableSchedule for User-4

    [Documentation]   Get next available schedule for multiple users.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME353}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME353}
    
    # clear_service   ${PUSERNAME353}
    # clear_appt_schedule   ${PUSERNAME353}
    
    ${PUSERPH1}  ${u_id} =  Create and Configure Sample User
    Set Suite Variable  ${PUSERPH1}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}  provider=${u_id}
    
    ${DAY1}=  db.add_timezone_date  ${tz}  1
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  5  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${PUSERNAME59}

    # clear_service   ${PUSERNAME59}
    # clear_appt_schedule   ${PUSERNAME59}
    # clear_service   ${PUSERNAME59}
    # clear_appt_schedule   ${PUSERNAME59}

    ${PUSERPH2}  ${u_id1} =  Create and Configure Sample User
    Set Suite Variable  ${PUSERPH2}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id1}=  Create Sample Service   ${SERVICE2}   provider=${u_id1}
    
    ${DAY11}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${time_now}=   db.get_time_by_timezone  ${tz}
    ${sTime1}=  add_two  ${time_now}   ${delta1+5}
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule    ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY11}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id1}  provider=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${var1}=  Set Variable  ${pid1}-${lid}-${u_id}
    ${var2}=  Set Variable   ${pid}-${lid1}-${u_id1}

    ${resp}=    Get NextAvailableSchedule By multi Provider Location and User    ${var1}  ${var2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()[0]}"  availableSlots
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}

    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}   ${u_id1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['id']}    ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['name']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['location']['id']}    ${lid1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['startDate']}     ${DAY11}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['timeDuration']}   ${duration1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['availableDate']}     ${DAY11}
    Should Be Equal As Strings  ${resp.json()[1]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()[1]}"  availableSlots
    ${sch_length1}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength1}=  Get Length  ${resp.json()[1]['availableSlots']['availableSlots']}
    Should Be Equal As Integers  ${sLength1}  ${sch_length1}

JD-TC-NextAvailableSchedule for User-5

    [Documentation]   Get next available schedule without login

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    # Should Contain  "${resp.json()[0]}"  availableSlots

JD-TC-NextAvailableSchedule for User-6

    [Documentation]   Get next available schedule with consumer login

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME3}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME3}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME3}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME3}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    # Should Contain  "${resp.json()[0]}"  availableSlots

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-NextAvailableSchedule for User-UH1

    [Documentation]   Get next available schedule for user with invalid account id

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${rand_pid}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${rand_pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH2

    [Documentation]   Get next available schedule for user with invalid location id

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${rand_lid}=  FakerLibrary.Random Int  min=100  max=1000

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${rand_lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH3

    [Documentation]   Get next available schedule for user with invalid user id

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${rand_uid}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${rand_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${rand_uid}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ACCOUNT_NOT_EXIST}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH4

    [Documentation]   Get next available schedule for user with Empty location id

    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${EMPTY}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH5

    [Documentation]   Get next available schedule for user with Empty account id
    
    ${pid}=  get_acc_id  ${PUSERNAME340}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME340}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${EMPTY}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

