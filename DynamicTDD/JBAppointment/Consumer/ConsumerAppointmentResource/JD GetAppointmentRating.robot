*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Rating
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}   Bleach
${SERVICE3}   Makeup
${SERVICE4}   FacialBody6
${SERVICE2}   MakeupHair6
${self}       0

*** Test Cases ***

JD-TC-GetAppointmentRating-1

	[Documentation]    Get Appointment Rating filter by account id.
	
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_rating    ${PUSERNAME200}

    ${pid}=  get_acc_id  ${PUSERNAME200}
    Set Suite Variable  ${pid} 
 
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME200}

    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}

    ${SERVICE3}=   FakerLibrary.name
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}

    ${SERVICE4}=   FakerLibrary.name
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${s_id4}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

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
    Set Suite Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${rating1}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating1}
    ${comment1}=   FakerLibrary.word
    Set Suite Variable   ${comment1}
    ${resp}=  Add Appointment Rating  ${pid}  ${apptid1}   ${rating1}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id    ${pid}    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}  ${apptid1}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment1}

    ${resp}=   Get Appointment Rating   account-eq=${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}      ${s_id}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}    1

JD-TC-GetAppointmentRating-2

    [Documentation]  Get Multiple Appointment Ratings filter by account id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location By Id   ${lid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1} 

    ${DAY2}=  db.add_timezone_date  ${tz}  6  
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    # ${rating2}=  Random Int  min=1   max=5
    # Set Suite Variable   ${rating2}
    ${comment2}=   FakerLibrary.word
    Set Suite Variable   ${comment2}
    ${resp}=  Add Appointment Rating  ${pid}  ${apptid2}   ${rating1}   ${comment2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Appointment By Id    ${pid}    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}  ${apptid2}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment2}    
    
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid}
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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id3}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    # ${rating3}=  Random Int  min=1   max=5
    # Set Suite Variable   ${rating3}
    ${comment3}=   FakerLibrary.word
    Set Suite Variable  ${comment3}
    ${resp}=  Add Appointment Rating  ${pid}  ${apptid3}   ${rating1}   ${comment3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Appointment By Id    ${pid}    ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}  ${apptid3}  
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}  ${rating1}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}  ${comment3}

    ${resp}=  Get Appointment Rating   account-eq=${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}        ${apptid3}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}        ${apptid2}
    Should Be Equal As Strings  ${resp.json()[2]['uuid']}        ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[2]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment3}
    Should Be Equal As Strings  ${resp.json()[1]['feedback'][0]['comments']}  ${comment2}
    Should Be Equal As Strings  ${resp.json()[2]['feedback'][0]['comments']}  ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}      ${s_id3}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}      ${s_id2}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}      ${s_id}

JD-TC-GetAppointmentRating-3

    [Documentation]  Get Appointment Rating filter by rating.  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_queue    ${PUSERNAME101}
    clear_service  ${PUSERNAME101}
    clear_rating    ${PUSERNAME101}
    
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable     ${pkgId}   ${pkg_id[0]}

    ${resp}=  Change License Package  ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${pid1}=  get_acc_id  ${PUSERNAME101}
    Set Suite Variable  ${pid1} 
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME101}

    ${SERVICE1}=   FakerLibrary.name
    ${ser_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${ser_id}
    
    ${SERVICE2}=   FakerLibrary.name
    ${ser_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${ser_id2}

    ${SERVICE3}=   FakerLibrary.name
    ${ser_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${ser_id3}

    ${SERVICE4}=   FakerLibrary.name
    ${ser_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${ser_id4}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${ser_id}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${schedule_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${schedule_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${schedule_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${ser_id3}  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${schedule_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${schedule_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${schedule_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${rating}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating}
    ${resp}=  Add Appointment Rating  ${pid}  ${apptid4}   ${rating}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${schedule_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${schedule_id}   ${pid1}
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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable   ${DAY2}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${ser_id}  ${schedule_id}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid5}  ${apptid[0]}
  
    ${resp}=  Add Appointment Rating  ${pid1}  ${apptid5}   ${rating}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating   rating-eq=${rating}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}    ${apptid5}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}    ${apptid4}
    # Should Be Equal As Strings  ${resp.json()[2]['uuid']}    ${apptid3}
    # Should Be Equal As Strings  ${resp.json()[3]['uuid']}    ${apptid2}
    # Should Be Equal As Strings  ${resp.json()[4]['uuid']}    ${apptid1}

JD-TC-GetAppointmentRating-4

    [Documentation]  Get Appointment Rating filter by service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location By Id   ${lid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${schedule_id}   ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${schedule_id}   ${pid1}
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
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid1}  ${ser_id}  ${schedule_id}  ${DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid6}  ${apptid[0]}

    ${resp}=  Add Appointment Rating  ${pid1}  ${apptid6}   ${rating1}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating   service-eq=${ser_id}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}              ${ser_id}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}              ${ser_id}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid6}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}                       ${apptid5} 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

JD-TC-GetAppointmentRating-5

    [Documentation]  Get Appointment Rating filter by appointment id.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating   uId-eq=${apptid4}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1 
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid4}
    
JD-TC-GetAppointmentRating-6

    [Documentation]  Get Appointment Rating filter by rating and account id.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating    rating-eq=${rating}  account-eq=${pid}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid4}

JD-TC-GetAppointmentRating-7

    [Documentation]  Get Appointment Rating filter by rating and service id.

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating    rating-eq=${rating1}  service-eq=${s_id}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1 

    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid1}
    
JD-TC-GetAppointmentRating-8

    [Documentation]  Get Appointment Rating filter by past date. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location By Id   ${lid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${DAY2}=  db.subtract_timezone_date  ${tz}   2
    ${resp}=  Get Appointment Rating    createdDate-eq=${DAY2}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

JD-TC-GetAppointmentRating-UH1

    [Documentation]  Trying to get Appointments Rating With out login by Consumer

    ${resp}=  Get Appointment Rating    account-eq=${pid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-GetAppointmentRating-UH2

    [Documentation]  Get Appointment Rating filter by invalid rating.

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating    rating-eq=-1
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

*** comment ***

JD-TC-GetAppointmentRating-UH1

    [Documentation]  Get Appointment Rating filter by another providerid 

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating    account-eq=${pid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

JD-TC-GetAppointmentRating-5

    [Documentation]  Get Appointment Rating filter by created date.

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating    createdDate-eq=${DAY1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}              ${s_id3}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}              ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid3}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}                       ${apptid1} 

