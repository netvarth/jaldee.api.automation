*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Schedule Slots
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${self}         0
&{empty_dict}
@{providers}

*** Test Cases ***

JD-TC-GetScheduleSlotsTodayByLocationandService-1
    [Documentation]  Get slots today when provider has only 1 schedule, 1 location and 1 service

    ${providers}=   Get File    /ebs/TDD/varfiles/providers.py
    ${pro_list}=   Split to lines  ${providers}
    ${length}=  Get Length   ${pro_list}
    ${providers1}=   Create List

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =
        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}    200
        ${licid}  ${licname}=  get_highest_license_pkg
        ${resp3}=  Get Business Profile
        Log   ${resp3.json()}
        Should Be Equal As Strings  ${resp3.status_code}  200
        IF  '${resp3.json()['licensePkgID']}' == '${licid}'   
            Append To List   ${providers1}   ${pro_num}
        END
    END
    
    Log   ${providers1} 
    ${pro_len}=  Get Length   ${providers1}
    ${pro_len}=    Evaluate  ${pro_len}-1
    ${index}=   Random Int  min=0  max=${pro_len}
    Set Suite Variable  ${ProviderPH}  ${providers1[${index}]}

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${ProviderPH}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}
        ${resp1}=   Enable Appointment
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Suite variable  ${lic2}  ${highest_package[0]}
    
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${l_id}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id}  ${duration}  ${bool1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id}     ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END
    
JD-TC-GetScheduleSlotsTodayByLocationandService-2
    [Documentation]  Get slots today when provider has 2 schedules with same location and service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id}  ${duration}  ${bool1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id}     ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['scheduleId']}  ${sch_id1}
    Should Be Equal As Strings  ${resp.json()[1]['scheduleName']}  ${schedule_name}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[1]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[1]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[1]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[1]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[1]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END

JD-TC-GetScheduleSlotsTodayByLocationandService-3
    [Documentation]  Get slots today when provider has 2 schedules with different location and same service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id1}=  Create Sample Location
    Set Suite Variable  ${l_id1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id1}  ${duration}  ${bool1}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id1}     ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id2}
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    # Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()[1]['scheduleId']}  ${sch_id1}
    # Should Be Equal As Strings  ${resp.json()[1]['scheduleName']}  ${schedule_name}
    # Should Be Equal As Strings  ${resp.json()[2]['scheduleId']}  ${sch_id2}


    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetScheduleSlotsTodayByLocationandService-4
    [Documentation]  Get slots today when provider has multiple schedules with same location and different services

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id1}  ${duration}  ${bool1}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id1}     ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id3}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END

JD-TC-GetScheduleSlotsTodayByLocationandService-5
    [Documentation]  Get slots today when provider has single schedule with different services

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id2}=  Create Sample Location
    Set Suite Variable   ${l_id2}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${SERVICE3}=   FakerLibrary.name
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable   ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    Set Suite Variable   ${duration}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id2}  ${duration}  ${bool1}   ${s_id2}    ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id4}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id2}     ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id4}
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END

JD-TC-GetScheduleSlotsTodayByLocationandService-UH1
    [Documentation]  Get slots today when provider has schedule disabled

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id4}     apptState=${Qstate[0]}

    ${resp}=  Disable Appointment Schedule  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id4}     apptState=${Qstate[1]}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id2}     ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    # ${st}=  timeto24hr  ${sTime1}
    # FOR  ${index}  IN RANGE  ${sch_length}
    #     ${muldur}=  Evaluate  (${index}+1)*${duration}
    #     ${et12}=  add_two  ${sTime1}  ${muldur}
    #     ${et}=  timeto24hr  ${et12}
        
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
    #     Set Test Variable  ${st}  ${et}
    # END

JD-TC-GetScheduleSlotsTodayByLocationandService-UH2
    [Documentation]  Get slots today when provider has service disabled

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${RESP}=  Disable service  ${s_id2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id2}     ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    # ${st}=  timeto24hr  ${sTime1}
    # FOR  ${index}  IN RANGE  ${sch_length}
    #     ${muldur}=  Evaluate  (${index}+1)*${duration}
    #     ${et12}=  add_two  ${sTime1}  ${muldur}
    #     ${et}=  timeto24hr  ${et12}
        
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
    #     Set Test Variable  ${st}  ${et}
    # END

JD-TC-GetScheduleSlotsTodayByLocationandService-UH3
    [Documentation]  Get slots today when provider has location disabled

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Location  ${l_id2}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id2}     ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    # ${st}=  timeto24hr  ${sTime1}
    # FOR  ${index}  IN RANGE  ${sch_length}
    #     ${muldur}=  Evaluate  (${index}+1)*${duration}
    #     ${et12}=  add_two  ${sTime1}  ${muldur}
    #     ${et}=  timeto24hr  ${et12}
        
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
    #     Set Test Variable  ${st}  ${et}
    # END

JD-TC-GetScheduleSlotsTodayByLocationandService-UH4
    [Documentation]  Get slots today when provider doesn't have a schedule for today

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id3}=  Create Sample Location
    Set Suite Variable   ${l_id3}
    ${SERVICE4}=   FakerLibrary.name
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${s_id4}
 

    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id3}  ${duration}  ${bool1}   ${s_id4}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id5}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id4}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id5}
    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}
    # ${st}=  timeto24hr  ${sTime1}
    # FOR  ${index}  IN RANGE  ${sch_length}
    #     ${muldur}=  Evaluate  (${index}+1)*${duration}
    #     ${et12}=  add_two  ${sTime1}  ${muldur}
    #     ${et}=  timeto24hr  ${et12}
        
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
    #     Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
    #     Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
    #     Set Test Variable  ${st}  ${et}
    # END

# *** comment ***
JD-TC-GetScheduleSlotsTodayByLocationandService-UH5
    [Documentation]  Get slots today when provider has a holiday

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=   Get Holiday By Id   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 
    Verify Response    ${resp}  description=${desc}  id=${holidayId} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  

    

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id3}  ${duration}  ${bool1}   ${s_id4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id3}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id4}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  0
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END

JD-TC-GetScheduleSlotsTodayByLocationandService-UH6
    [Documentation]  Get slots today with invalid location id

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${location}=    FakerLibrary.Building Number

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${location}     ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    
JD-TC-GetScheduleSlotsTodayByLocationandService-UH7
    [Documentation]  Get slots today with invalid service id

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${s_id4}=    FakerLibrary.Building Number

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

# *** comment ***

JD-TC-GetScheduleSlotsTodayByLocationandService-UH8
    [Documentation]  Get slots today with location id of a different provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id4}=  Create Sample Location

    ${SERVICE5}=   FakerLibrary.name
    ${s_id5}=  Create Sample Service  ${SERVICE5}
    Set Suite Variable   ${s_id5}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id4}     ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-GetScheduleSlotsTodayByLocationandService-UH9
    [Documentation]  Get slots today with service id of a different provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${l_id4}=  Create Sample Location

    ${SERVICE5}=   FakerLibrary.name
    ${s_id5}=  Create Sample Service  ${SERVICE5}
    Set Suite Variable   ${s_id5}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-GetScheduleSlotsTodayByLocationandService-UH10
    [Documentation]  Get slots today with Provider login 

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-GetScheduleSlotsTodayByLocationandService-UH11
    [Documentation]  Get slots today without login

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id3}     ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetScheduleSlotsTodayByLocationandService-6
    [Documentation]  Get slots today when service has consumer parallel serving set

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id4}=  Create Sample Location
    # Set Suite Variable   ${l_id3}
    ${SERVICE5}=   FakerLibrary.name
    ${s_id5}=  Create Sample Service  ${SERVICE5}
    Set Suite Variable   ${s_id5}
 

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=4  max=10
    ${consumer_parallel}=  FakerLibrary.Random Int  min=1  max=3
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumer_parallel}  ${l_id4}  ${duration}  ${bool1}   ${s_id5}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id4}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id5}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id4}     ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        Set Test Variable  ${st}  ${et}
    END

JD-TC-GetScheduleSlotsTodayByLocationandService-7
    [Documentation]  Get slots today when service has lead time set

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${l_id5}=  Create Sample Location
    # Set Suite Variable   ${l_id3}
    ${SERVICE6}=   FakerLibrary.name
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE6}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id6}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=4  max=10
    ${consumer_parallel}=  FakerLibrary.Random Int  min=1  max=3
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumer_parallel}  ${l_id5}  ${duration}  ${bool1}   ${s_id6}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id7}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id5}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id6}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id5}     ${s_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetScheduleSlotsTodayByLocationandService-8
    [Documentation]  Get slots today when service has channel based label set

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Service Label Config   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${channel_id1}   ${resp.json()[0]['id']}  
    Set Suite Variable  ${channel_id2}   ${resp.json()[1]['id']} 
    Set Suite Variable  ${channel_id3}   ${resp.json()[2]['id']} 

    Set Suite Variable  ${channel_name1}   ${resp.json()[0]['name']}  
    Set Suite Variable  ${channel_name2}   ${resp.json()[1]['name']} 
    Set Suite Variable  ${channel_name3}   ${resp.json()[2]['name']} 

    Set Suite Variable  ${channel_disname1}   ${resp.json()[0]['displayName']}  
    Set Suite Variable  ${channel_disname2}   ${resp.json()[1]['displayName']} 
    Set Suite Variable  ${channel_disname3}   ${resp.json()[2]['displayName']} 

    Set Suite Variable  ${label_id1}   ${resp.json()[0]['serviceLabels'][0]['id']}  
    Set Suite Variable  ${label_id2}   ${resp.json()[1]['serviceLabels'][0]['id']}  
    Set Suite Variable  ${label_id3}   ${resp.json()[2]['serviceLabels'][0]['id']}  
   
    Set Suite Variable  ${label_name1}   ${resp.json()[0]['serviceLabels'][0]['name']}  
    Set Suite Variable  ${label_name2}   ${resp.json()[1]['serviceLabels'][0]['name']}  
    Set Suite Variable  ${label_name3}   ${resp.json()[2]['serviceLabels'][0]['name']}  
    
    Set Suite Variable  ${label_disname1}   ${resp.json()[0]['serviceLabels'][0]['displayName']}  
    Set Suite Variable  ${label_disname2}   ${resp.json()[1]['serviceLabels'][0]['displayName']}  
    Set Suite Variable  ${label_disname3}   ${resp.json()[2]['serviceLabels'][0]['displayName']}  
   
    ${channel_ids}=  Create List   ${channel_id1}   

    ${resp}=  Enable Disable Channel    ${account_id}  ${actiontype[0]}  ${channel_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Id  ${account_id}  
    Log  ${resp.content}
 	Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['subscriptionChannels']['${channel_id1}']}   ${channel_disname1}
   
    ${resp}=  SuperAdminLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Labels
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}   ${resp.json()[0]['id']}  

    Should Be Equal As Strings  ${resp.json()[0]['label']}        ${label_name1}
    Should Be Equal As Strings  ${resp.json()[0]['displayName']}  ${label_disname1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}       ${Qstate[0]}


    ${l_id6}=  Create Sample Location
    # Set Suite Variable   ${l_id3}
    ${SERVICE7}=   FakerLibrary.name
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${srv_duration}=   Random Int   min=10   max=20
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Service  ${SERVICE7}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${s_id7}  ${resp.json()}

    ${resp}=   Get Service By Id  ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_ids}=  Create List   ${label_id} 

    ${resp}=  Apply Labels To Service    ${s_id7}   ${label_ids}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['label']['jaldee_homeo']}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.json()['channelRestricted']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['leadTime']}               0

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  add_timezone_time  ${tz}  3  30  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.name
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${consumer_parallel}=  FakerLibrary.Random Int  min=1  max=3
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${consumer_parallel}  ${l_id6}  ${duration}  ${bool1}   ${s_id7}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id7}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id6}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id7}
    # Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots Today By Location and Service    ${account_id}    ${l_id6}     ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

