*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment, Schedule
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${self}     0
${digits}       0123456789
@{dom_list}
@{emptylist}

*** Test Cases ***

JD-TC-MonthlySchedule-1
    [Documentation]  Provider checks monthly schedule availability
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    clear_service   ${PUSERNAME31}
    # clear_location  ${PUSERNAME31}
    # clear_customer   ${PUSERNAME31}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Locations
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    # ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length}
    END

JD-TC-MonthlySchedule-2
    [Documentation]  Provider checks monthly schedule availability when today's schedule time is over
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
  
    # ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  ${delta+15}
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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
    # 

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${now}=  db.get_time_by_timezone  ${tz}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    # FOR  ${i}  IN RANGE  ${len}
    #     ${DAY2}=  db.add_timezone_date  ${tz}  ${i+1}
    #     Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
    #     ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
    #     Should Be Equal As Integers  ${slot_Len}  ${sch_length}
    # END
    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        ${slot_Len}=  Run Keyword If  "${DAY2}" != "${DAY1}"   Get Length   ${resp.json()[${i}]['availableSlots']}
        Run Keyword If  "${DAY2}" != "${DAY1}"   
        ...    Run Keywords
        ...   Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
        ...   AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length}
        ...   ELSE
        ...   Verify Response List  ${resp}  ${i}  date=${DAY2}  reason=${reason[2]}
        
    END


JD-TC-MonthlySchedule-3
    [Documentation]  Provider checks monthly schedule availability when weekends are non working days

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${today}=  get_timezone_weekday  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # 

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        ${weekday}=   get_weekday_by_date   ${DAY2}
        # Verify Response List  ${resp}  ${i}   date=${DAY2}  reason=${reason[0]}
        
        ${slot_Len}=  Run Keyword If  $weekday in $list   Get Length   ${resp.json()[${i}]['availableSlots']}
        
        Run Keyword If   $weekday in $list
        ...   Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
        ...   AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length}  
        ...   ELSE IF   $weekday in ["6","7"]  
        ...     Verify Response List  ${resp}  ${i}   date=${DAY2}  reason=${reason[0]}
    END


JD-TC-MonthlySchedule-4
    [Documentation]  Provider checks monthly schedule availability when there are Holidays

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${today}=  get_timezone_weekday  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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
    

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${holidayname}=   FakerLibrary.word
    ${rand}=  FakerLibrary.Random Int  min=1  max=28
    ${holiday_date}=  db.add_timezone_date  ${tz}  ${rand}
    # ${resp}=  Create Holiday  ${holiday_date}  ${holidayname}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${hId}  ${resp.json()}
    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${holiday_date}  ${holiday_date}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}


    ${resp}=   Get Holiday By Id  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        ${weekday}=   get_weekday_by_date   ${DAY2}
        # Verify Response List  ${resp}  ${i}   date=${DAY2}  reason=${reason[0]}
        
        ${slot_Len}=  Run Keyword If  "${DAY2}" != "${holiday_date}"   Get Length   ${resp.json()[${i}]['availableSlots']}
        Log many   ${resp}  ${i}
        Run Keyword If   "${DAY2}" != "${holiday_date}"
        ...    Run Keywords
        ...     Verify Response List   ${resp}   ${i}   scheduleId=${sch_id}   scheduleName=${schedule_name}   date=${DAY2}
        ...     AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length}
        ...   ELSE
        ...     Verify Response List   ${resp}   ${i}   date=${DAY2}  reason=${reason[0]}
        
        
    END


JD-TC-MonthlySchedule-5
    [Documentation]  Provider checks monthly schedule availability when there are more than one schedule for a service in the same location

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    Log   ${licresp.json()}
    # FOR  ${pos}  IN RANGE  ${liclen}
    Set Test Variable  ${pkgId}  ${licresp.json()[0]['pkgId']}
    Set Test Variable  ${pkg_name}  ${licresp.json()[0]['displayName']}
    # END
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length    ${len}    
    FOR   ${a}  IN RANGE   0    ${length}    

        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Exit For Loop If  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' == '${pkgId}'
                
    END
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME${a}}
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Location By Id   ${lid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME${a}}
    
    ${today}=  get_timezone_weekday  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}

    ${sch_length1}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength1}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength1}  ${sch_length1}
    @{slots1}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length1}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots1}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots1}

    ${sTime2}=  add_two   ${eTime1}  15
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/2}
        ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}    ${parallel2}  ${lid}  ${duration2}  ${bool2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}

    ${sch_length2}=  get_slot_length  ${delta2}  ${duration2}
    ${sLength2}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength2}  ${sch_length2}
    @{slots2}=  Create List
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${sch_length2}
        ${muldur}=  Evaluate  (${index}+1)*${duration2}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots2}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots2}

    ${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    ${flag}=  Set Variable  ${0}
    ${j}=  Set Variable  ${0}
    ${DAY2}=  db.get_date_by_timezone  ${tz}

    FOR  ${i}  IN RANGE  ${len}
        # ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        ${flag}=  Evaluate  ${flag}+1
        ${slot_Len}=  Run Keyword If  '${resp.json()[${i}]['scheduleId']}' == '${sch_id1}'   Get Length   ${resp.json()[${i}]['availableSlots']}
        ...     ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}'   Get Length   ${resp.json()[${i}]['availableSlots']}

        Run Keyword IF  '${resp.json()[${i}]['scheduleId']}' == '${sch_id1}'  
        ...    Run Keywords 
        ...    Verify Response List  ${resp}  ${i}  scheduleId=${sch_id1}   scheduleName=${schedule_name1}  date=${DAY2}
        ...    AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length1}
        ...    ELSE IF     '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}'   
        ...    Run Keywords
        ...    Verify Response List  ${resp}  ${i}  scheduleId=${sch_id2}   scheduleName=${schedule_name2}  date=${DAY2}
        ...    AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length2}

        ${j}=  Run Keyword If  '${flag}' >= '${len1}'  Evaluate  ${j}+1
        ...     ELSE  Set Variable  ${j}
        ${DAY2}=  Run Keyword If  '${flag}' >= '${len1}'  db.add_timezone_date  ${tz}   ${j}
        ...     ELSE  Set Variable  ${DAY2}
        ${flag}=  Run Keyword If  '${flag}' >= '${len1}'  Set Variable  ${0}
        ...     ELSE  Set Variable  ${flag}

    END


JD-TC-MonthlySchedule-6
    [Documentation]  Provider checks monthly schedule availability when there are more than one schedule for a service in different locations
     
     



  #  ${licresp}=   Get Licensable Packages
   # Should Be Equal As Strings   ${licresp.status_code}   200
   # ${liclen}=  Get Length  ${licresp.json()}
   # Log   ${licresp.json()}
   # Set Test Variable  ${pkgId}  ${licresp.json()[0]['pkgId']}
   # Set Test Variable  ${pkg_name}  ${licresp.json()[0]['displayName']}

    ${billable_providers}   ${multilocPro}=    Multiloc and Billable highest license Providers    min=0   max=260
     Log Many  ${billable_providers} 	${multilocPro}
    Set Suite Variable   ${billable_providers}
    Set Suite Variable   ${multilocPro}

     ${resp}=  Encrypted Provider Login  ${multilocPro[5]}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    
   # ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=30   max=50
   # Log   ${multilocPro}
   # Set Suite Variable   ${multilocPro}
   # ${mlp_length}=   Get Length   ${multilocPro}
   # FOR   ${a}  IN RANGE   0    ${mlp_length}    

    #    ${ml_pro}=  Evaluate  random.choice($multilocPro)  random
     #   ${resp}=  Encrypted Provider Login  ${ml_pro}  ${PASSWORD}
     #   Log   ${resp.json()}
     #   Should Be Equal As Strings  ${resp.status_code}  200
     #   Exit For Loop If  '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' == '${pkgId}'
                
    #END
    
   # clear_service   ${ml_pro}
     clear_service   ${multilocPro[5]}
   # clear_location  ${multilocPro[5]}
    

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END
    ${lid2}=  Create Sample Location

    clear_appt_schedule   ${multilocPro[5]}
    
    ${today}=  get_timezone_weekday  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}

    ${sch_length1}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength1}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength1}  ${sch_length1}
    @{slots1}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length1}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots1}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots1}

    ${sTime2}=  add_two   ${eTime1}  15
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/2}
        ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}    ${parallel2}  ${lid2}  ${duration2}  ${bool2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}

    ${sch_length2}=  get_slot_length  ${delta2}  ${duration2}
    ${sLength2}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength2}  ${sch_length2}
    @{slots2}=  Create List
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${sch_length2}
        ${muldur}=  Evaluate  (${index}+1)*${duration2}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots2}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots2}

    ${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id1}   scheduleName=${schedule_name1}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length1}
    END

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id2}   scheduleName=${schedule_name2}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length2}
    END


JD-TC-MonthlySchedule-7
    [Documentation]  Provider checks monthly schedule availability when there are more than one schedule in different locations for different services

    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings   ${licresp.status_code}   200
    # ${liclen}=  Get Length  ${licresp.json()}
    # Log   ${licresp.json()}
    # # FOR  ${pos}  IN RANGE  ${liclen}
    # Set Test Variable  ${pkgId}  ${licresp.json()[0]['pkgId']}
    # ${pkgId}    Convert To Integer  ${pkgId}
    # Set Test Variable  ${pkg_name}  ${licresp.json()[0]['displayName']}
    # # END
    # ${mlp_length}=   Get Length   ${multilocPro}
    # FOR   ${a}  IN RANGE   0    ${mlp_length}    

    #     ${ml_pro}=  Evaluate  random.choice($multilocPro)  random
    #     ${resp}=  Encrypted Provider Login  ${ml_pro}  ${PASSWORD}
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${decrypted_data}=  db.decrypt_data  ${resp.content}
    #     Log  ${decrypted_data}
    #     Exit For Loop If  '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' ==  '${pkgId}'
                
    # END

    # clear_service   ${ml_pro}

    clear_service   ${PUSERNAME67}
    clear_multilocation   ${PUSERNAME67}
    clear_queue     ${PUSERNAME67}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=    FakerLibrary.Word
    ${s_id2}=  Create Sample Service  ${SERVICE2}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    ${lid2}=  Create Sample Location

    clear_appt_schedule   ${PUSERNAME67}
    
    ${today}=  get_timezone_weekday  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}

    ${sch_length1}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength1}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength1}  ${sch_length1}
    @{slots1}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length1}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots1}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots1}

    ${sTime2}=  add_two   ${eTime1}  15
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/2}
        ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}    ${parallel2}  ${lid2}  ${duration2}  ${bool2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name2}  scheduleId=${sch_id2}

    ${sch_length2}=  get_slot_length  ${delta2}  ${duration2}
    ${sLength2}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength2}  ${sch_length2}
    @{slots2}=  Create List
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${sch_length2}
        ${muldur}=  Evaluate  (${index}+1)*${duration2}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots2}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots2}

    ${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id1}   scheduleName=${schedule_name1}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length1}
    END

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id2}   scheduleName=${schedule_name2}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length2}
    END

JD-TC-MonthlySchedule-8
    [Documentation]  Provider checks monthly schedule availability when another provider has holiday
    
    
    clear_appt_schedule   ${PUSERNAME30}
    clear_appt_schedule   ${PUSERNAME31}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${DAY1}=  db.get_date_by_timezone  ${tz}     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}    ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${rand}=  FakerLibrary.Random Int  min=1  max=28
    ${holiday_date}=  db.add_timezone_date  ${tz}  ${rand}
    # ${resp}=  Create Holiday  ${holiday_date}  ${holidayname}  ${sTime1}  ${eTime1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${hId}  ${resp.json()}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${holiday_date}  ${holiday_date}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}


    ${resp}=   Get Holiday By Id  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}     
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
        ${slot_Len}=  Get Length   ${resp.json()[${i}]['availableSlots']}
        Should Be Equal As Integers  ${slot_Len}  ${sch_length}
    END

JD-TC-MonthlySchedule-UH1
    [Documentation]  Provider checks monthly schedule availability another provider's location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=    FakerLibrary.Word
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"


JD-TC-MonthlySchedule-UH2
    [Documentation]  Provider checks monthly schedule availability for another provider's service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id1}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${SERVICE1}=    FakerLibrary.Word
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}

    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    # @{slots}=  Create List
    # ${st}=  timeto24hr  ${sTime1}
    # FOR  ${index}  IN RANGE  ${sch_length}
    #     ${muldur}=  Evaluate  (${index}+1)*${duration}
    #     ${et12}=  add_two  ${sTime1}  ${muldur}
    #     ${et}=  timeto24hr  ${et12}
    #     Append To List   ${slots}  ${st}-${et}
    #     Set Test Variable   ${st}   ${et}
        
    # END

    # Log   ${slots}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"


JD-TC-MonthlySchedule-UH3
    [Documentation]  Provider checks monthly schedule availability without login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"


JD-TC-MonthlySchedule-UH4
    [Documentation]  Provider checks monthly schedule availability when there are no schedules in an existing location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    clear_appt_schedule   ${PUSERNAME31}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${SERVICE_NOT_FOUND}"


JD-TC-MonthlySchedule-UH5
    [Documentation]  Provider checks monthly schedule availability when there are no schedules for a service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    clear_appt_schedule   ${PUSERNAME31}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${SERVICE_NOT_FOUND}"


JD-TC-MonthlySchedule-UH6
    [Documentation]  Provider checks monthly schedule availability by consumer login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-MonthlySchedule-UH7
    [Documentation]  Provider checks monthly schedule availability by another provider's login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"


JD-TC-MonthlySchedule-UH8
    [Documentation]  Provider checks monthly schedule availability with invalid service id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    # ${rand int}=    Generate Random String    length=4    chars=[NUMBERS]
    # ${s_id}=    Convert To Integer    ${rand int}
    ${s_id}=  FakerLibrary.Numerify  %%%%%%

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${SERVICE_NOT_FOUND}"


JD-TC-MonthlySchedule-UH9
    [Documentation]  Provider checks monthly schedule availability with invalid location id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  #  Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${rand int}=    FakerLibrary.Numerify  %%%%%%
    ${lid}=    Convert To Integer    ${rand int}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${LOCATION_NOT_FOUND}"


JD-TC-MonthlySchedule-UH10
    [Documentation]  Provider checks monthly schedule availability when there are no more available slots for a future date

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME31}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=${delta}  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
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

    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length   ${resp.json()['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    @{slots}=  Create List
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        Append To List   ${slots}  ${st}-${et}
        Set Test Variable   ${st}   ${et}
        
    END

    Log   ${slots}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uid=${apptid1}   appointmentEncId=${encId}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length   ${resp.json()}

    FOR  ${i}  IN RANGE  ${len}
        ${DAY2}=  db.add_timezone_date  ${tz}  ${i}
        ${slot_Len}=  Run Keyword If  "${DAY2}" != "${DAY3}"   Get Length   ${resp.json()[${i}]['availableSlots']}
        Run Keyword If  "${DAY2}" != "${DAY3}"   
        ...    Run Keywords
        ...   Verify Response List  ${resp}  ${i}  scheduleId=${sch_id}   scheduleName=${schedule_name}  date=${DAY2}
        ...   AND   Should Be Equal As Integers  ${slot_Len}  ${sch_length}
        ...   ELSE
        ...   Verify Response List  ${resp}  ${i}  date=${DAY2}  reason=${reason[2]}
    END


# ..........timezone cases..............

JD-TC-MonthlySchedule-9

    [Documentation]  provider checks monthly schedule(today) for location in US (where one day difference in tz)

    clear_service   ${PUSERNAME229}
    clear_location   ${PUSERNAME229}
    clear_queue     ${PUSERNAME229}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME229}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME229}
    
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id1}=   Create Sample Service  ${SERVICE1}

    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${US_tz}  0  30  
    ${eTime1}=  add_timezone_time  ${US_tz}  1  00  
    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${DAY1}=  db.add_timezone_date  ${US_tz}  10       
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${loc_id1}  ${resp.json()}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Monthly Schedule Availability by Location and Service  ${loc_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}   ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}     ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}           ${DAY}

    