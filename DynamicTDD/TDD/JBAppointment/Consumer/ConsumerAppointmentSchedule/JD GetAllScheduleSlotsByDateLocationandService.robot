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
@{empty_list}

*** Test Cases ***

JD-TC-GetAllScheduleSlotsByDateLocationandService-1
    [Documentation]  Get slots for today when provider has only 1 schedule, 1 location and 1 service

    ${providers_list}=   Get File    /ebs/TDD/varfiles/providers.py
    ${pro_list}=   Split to lines  ${providers_list}
    ${length}=  Get Length   ${pro_list}

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =
        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        
        ${licid}  ${licname}=  get_highest_license_pkg
        IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' == '${licid}'   
            Append To List   ${providers}   ${pro_num}
        END
        # ${resp3}=  Get Business Profile
        # Log  ${resp3.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # IF  '${resp3.json()['licensePkgID']}' == '${licid}'   
        #     Append To List   ${providers}   ${pro_num}
        # END
    END

    ${pro_len}=  Get Length   ${providers}
    ${index}=   Random Int  min=0  max=${pro_len}
    Set Suite Variable  ${ProviderPH}  ${providers[${index}]}

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    # Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}
        ${resp1}=   Enable Appointment
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    clear_appt_schedule   ${ProviderPH}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${l_id}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime1}=  db.add_timezone_time  ${tz}   0  5
    Set Suite Variable  ${sTime1}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta1}
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    Set Suite Variable  ${parallel}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta1}
    Set Suite Variable  ${duration}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${l_id}  ${duration}  ${bool1}   ${s_id}
    Log  ${resp.content}
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

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${sch_length}=  get_slot_length  ${delta1}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-2
    [Documentation]  Get slots for a future date when provider has only 1 schedule, 1 location and 1 service

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  5   

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY2}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    ${sch_length}=  get_slot_length  ${delta1}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-3
    [Documentation]  Get slots for schedule last date when provider has only 1 schedule, 1 location and 1 service

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  10   

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY2}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    ${sch_length}=  get_slot_length  ${delta1}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-4
    [Documentation]  Get slots for schedule last date after updating schedule end date when provider has only 1 schedule, 1 location and 1 service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  10   

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}

    ${DAY3}=  db.add_timezone_date  ${tz}  15  

     ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${DAY3}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}    
    ...  ${resp.json()['location']['id']}  ${resp.json()['timeDuration']}  ${bool[0]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY3}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  12 

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY2}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    # Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    ${sch_length}=  get_slot_length  ${delta1}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}
    ${st}=  timeto24hr  ${sTime1}
    FOR  ${index}  IN RANGE  ${sch_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime1}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-UH1
    [Documentation]  Get slots for a day after schedule last date when provider has only 1 schedule, 1 location and 1 service

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  16 

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY2}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${empty_list}


JD-TC-GetAllScheduleSlotsByDateLocationandService-5
    [Documentation]  Get slots for today when provider has 2 schedules with same location and service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Service
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    # ${resp}=    Get Locations
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${l_id}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7 
    ${sTime2}=  add_timezone_time  ${tz}  0  ${delta1+5}
    Set Suite Variable  ${sTime2}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta2}
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    Set Suite Variable  ${eTime2}
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${delta2}
    Set Suite Variable  ${duration1}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel1}  ${parallel1}  ${l_id}  ${duration1}  ${bool1}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${delta1}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime1}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime1}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration1}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        
        END
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-6
    [Documentation]  Get slots when provider has 2 schedules with same location and service but 1 schedule has only 6 days of repeat interval

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

         
    ${ri2}=  Create List  1  2  3  4  5  6   
    ${ri1}=  Create List  1  2  3  4  5  6  7
    

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${ri2}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${resp.json()['location']['id']}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri1}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    ${curr_weekday}=  get_timezone_weekday  ${tz}
    ${daygap}=  Evaluate  7-${curr_weekday}
    ${DAY7}=  db.add_timezone_date  ${tz}  ${daygap}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY7}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY7}
            ${slot_length}=  get_slot_length  ${delta1}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime1}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime1}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY7}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        
        END
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-UH2
    [Documentation]  Get slots when provider has 2 schedules with same location and service but both schedules has only 6 days of repeat interval

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ri}=  Create List  1  2  3  4  5  6 
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${ri}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${resp.json()['location']['id']}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    ${curr_weekday}=  get_timezone_weekday  ${tz}
    ${daygap}=  Evaluate  7-${curr_weekday}
    ${DAY7}=  db.add_timezone_date  ${tz}  ${daygap}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY7}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${empty_list}


JD-TC-GetAllScheduleSlotsByDateLocationandService-7
    [Documentation]  Get slots and check if its available when schedule start time in current time

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ri}=  Create List  1  2  3  4  5  6  7
    ${ri2}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}

    ${resp}=  Disable Appointment Schedule  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptState']}  ${Qstate[1]}
    
    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${ri}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${sTime}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${resp.json()['location']['id']}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime}
    Should Be Equal As Strings  ${resp.json()['apptState']}  ${Qstate[1]}

    ${resp}=   Enable Appointment Schedule   ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${ri2}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${resp.json()['location']['id']}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri2}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    # ${curr_weekday}=  get_timezone_weekday  ${tz}
    # ${daygap}=  Evaluate  7-${curr_weekday}
    # ${DAY7}=  db.add_timezone_date  ${tz}  ${daygap}
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${mins_between}=  mins_diff  ${sTime}  ${etime}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${2}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${mins_between}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime}
            
            ${et12}=  add_two  ${sTime}  ${duration}
            ${et}=  timeto24hr  ${et12}
            
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][0]['time']}  ${st}-${et}
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][0]['noOfAvailbleSlots']}  ${parallel}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][0]['active']}      ${bool[0]}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][0]['capacity']}   ${parallel}
            Set Test Variable  ${st}  ${et}
            FOR  ${index}  IN RANGE  1  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration1}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        
        END
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-UH3
    [Documentation]  Get slots on a holiday

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ri}=  Create List  1  2  3  4  5  6  7
    ${ri2}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime1}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri2}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${holiday_date}=  db.add_timezone_date  ${tz}  ${d}  
    ${holidayname}=   FakerLibrary.word
    ${desc}=    FakerLibrary.name
    ${ri}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Holiday   ${recurringtype[1]}  ${ri}  ${holiday_date}  ${holiday_date}  ${EMPTY}  ${stime}  ${etime}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=   Get Holiday By Id  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    # ${curr_weekday}=  get_timezone_weekday  ${tz}
    # ${daygap}=  Evaluate  7-${curr_weekday}
    # ${DAY7}=  db.add_timezone_date  ${tz}  ${daygap}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${mins_between}=  mins_diff  ${sTime}  ${etime1}
    

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${holiday_date}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${holiday_date}
            ${slot_length}=  get_slot_length  ${mins_between}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  0
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${holiday_date}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration1}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  0
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        
        END
    END

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${hId}"


JD-TC-GetAllScheduleSlotsByDateLocationandService-8
    [Documentation]  Get slots when lead time is set for a service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${leadTime}=   Random Int   min=5   max=10
    ${leadTime}=   Set Variable  ${duration}
    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${EMPTY}   ${resp.json()['serviceDuration']}  ${status[0]}  ${btype}  ${bool[0]}  ${resp.json()['notificationType']}  ${EMPTY}  ${resp.json()['totalAmount']}  ${bool[0]}  ${bool[0]}  leadTime=${leadTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ri}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable   ${ri}
    ${ri2}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable   ${ri2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}
    # Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    # ${curr_weekday}=  get_timezone_weekday  ${tz}
    # ${daygap}=  Evaluate  7-${curr_weekday}
    # ${DAY7}=  db.add_timezone_date  ${tz}  ${daygap}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${mins_between}=  mins_diff  ${sTime}  ${etime}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${mins_between}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime}
            
            ${et12}=  add_two  ${sTime}  ${duration}
            ${et}=  timeto24hr  ${et12}
            
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][0]['time']}  ${st}-${et}
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][0]['noOfAvailbleSlots']}  ${parallel}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][0]['active']}      ${bool[0]}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][0]['capacity']}   ${parallel}
            Set Test Variable  ${st}  ${et}

            ${et12}=  add_two  ${sTime}  ${duration*2}
            ${et}=  timeto24hr  ${et12}
            
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][1]['time']}  ${st}-${et}
            Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][1]['noOfAvailbleSlots']}  ${parallel}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][1]['active']}      ${bool[0]}
            Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][1]['capacity']}   ${parallel}
            Set Test Variable  ${st}  ${et}
            FOR  ${index}  IN RANGE  2  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration1}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${parallel}
                Set Test Variable  ${st}  ${et}
            END
        
        END
    END
    
    
JD-TC-GetAllScheduleSlotsByDateLocationandService-9
    [Documentation]  Get slots when schedule has a different consumer parallel serving

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ri2}=  Create List  1  2  3  4  5  6  7

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Service  ${s_id}  ${resp.json()['name']}  ${EMPTY}   ${resp.json()['serviceDuration']}  ${status[0]}  ${btype}  ${bool[0]}  ${resp.json()['notificationType']}  ${EMPTY}  ${resp.json()['totalAmount']}  ${bool[0]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${parallelServing}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallelServing}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${parallelServing}  ${consumerparallelserving}  ${resp.json()['location']['id']}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallelServing}
    Should Be Equal As Strings  ${resp.json()['consumerParallelServing']}  ${consumerparallelserving}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri}
    Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${ri2}
    Set Test Variable  ${duration1}  ${resp.json()['timeDuration']}
    ${delta1}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${stime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel1}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel1}    ${resp.json()['consumerParallelServing']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # FOR   ${i}  IN RANGE   1   3
    #     ${DAYQ}=  db.add_timezone_date  ${tz}  ${i}
    #     ${DAYQ_weekday}=  get_weekday_by_date  ${DAYQ}
    #     Continue For Loop If   '${DAYQ_weekday}' == '7'
    #     Exit For Loop If  '${DAYQ_weekday}' != '7'
    # END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${mins_between}=  mins_diff  ${sTime}  ${etime}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${sch_len}
        IF  '${resp.json()[${i}]['scheduleId']}'=='${sch_id}'
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${mins_between}  ${duration}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration}
                ${et12}=  add_two  ${sTime}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallelserving}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${consumerparallelserving}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        ELSE IF   '${resp.json()[${i}]['scheduleId']}' == '${sch_id2}' 
            Should Be Equal As Strings  ${resp.json()[${i}]['scheduleName']}  ${schedule_name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['date']}  ${DAY1}
            ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
            ${sLength}=  Get Length  ${resp.json()[${i}]['availableSlots']}
            Should Be Equal As Integers  ${sLength}  ${slot_length}
            ${st}=  timeto24hr  ${sTime2}
            FOR  ${index}  IN RANGE  ${slot_length}
                ${muldur}=  Evaluate  (${index}+1)*${duration1}
                ${et12}=  add_two  ${sTime2}  ${muldur}
                ${et}=  timeto24hr  ${et12}
                ${active_slot}=  compare_slot_to_now  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  timezone=${tz}
                
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['time']}  ${st}-${et}
                Should Be Equal As Strings  ${resp.json()[${i}]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel1}
                # Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['capacity']}   ${consumerParallel1}
                IF  '${active_slot}' == 'True'
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[0]}
                ELSE
                    Should Be Equal As Strings   ${resp.json()[${i}]['availableSlots'][${index}]['active']}      ${bool[1]}
                END
                Set Test Variable  ${st}  ${et}
            END
        END
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-10
    [Documentation]  Get slots when provider has 2 schedules with different location and same service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${l_id1}=  Create Sample Location
    Set Suite Variable  ${l_id1}
    ${resp}=   Get Location ById  ${l_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    # ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${l_id1}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${resp.json()['services'][0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id1}
    Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel}    ${resp.json()['consumerParallelServing']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Set Test Variable  ${duration1}  ${resp.json()['timeDuration']}
    ${delta1}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${stime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallelServing1}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallelServing1}    ${resp.json()['consumerParallelServing']}
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY1}=  db.add_timezone_date  ${tz}  1 

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${stime2}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${stime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${ParallelServing1}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${parallelServing1}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${stime}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${stime}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-11
    [Documentation]  Get slots when provider has 2 schedules with same location and different service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${l_id}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
    Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel}    ${resp.json()['consumerParallelServing']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Set Test Variable  ${sTime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${duration1}  ${resp.json()['timeDuration']}
    ${delta2}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel1}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel1}    ${resp.json()['consumerParallelServing']}
    

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${Parallel1}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel1}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-12
    [Documentation]  Get slots when provider has 2 schedules with different location and different service

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${l_id1}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel}    ${resp.json()['consumerParallelServing']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Set Test Variable  ${stime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${duration1}  ${resp.json()['timeDuration']}
    ${delta2}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel1}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel1}    ${resp.json()['consumerParallelServing']}
    

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel1}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel1}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


JD-TC-GetAllScheduleSlotsByDateLocationandService-13
    [Documentation]  Get slots today when provider has single schedule with different services

    ${resp}=  Encrypted Provider Login  ${ProviderPH}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${SERVICE1}=   FakerLibrary.name
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  
    ...  ${resp.json()['parallelServing']}  ${resp.json()['consumerParallelServing']}  ${l_id1}  
    ...  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}
    Set Test Variable  ${stime}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${duration}  ${resp.json()['timeDuration']}
    ${delta}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel}    ${resp.json()['consumerParallelServing']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${l_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Set Test Variable  ${stime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime2}   ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${duration1}  ${resp.json()['timeDuration']}
    ${delta2}=  mins_diff  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${parallel1}  ${resp.json()['parallelServing']}  
    Set Test Variable  ${consumerParallel1}    ${resp.json()['consumerParallelServing']}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta2}  ${duration1}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime2}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration1}
        ${et12}=  add_two  ${sTime2}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel1}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel1}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${l_id1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${sch_len}  ${1}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleId']}  ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['scheduleName']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    ${slot_length}=  get_slot_length  ${delta}  ${duration}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${slot_length}
    ${st}=  timeto24hr  ${sTime}
    FOR  ${index}  IN RANGE  ${slot_length}
        ${muldur}=  Evaluate  (${index}+1)*${duration}
        ${et12}=  add_two  ${sTime}  ${muldur}
        ${et}=  timeto24hr  ${et12}
        ${active_slot}=  compare_slot_to_now  ${resp.json()[0]['availableSlots'][${index}]['time']}  timezone=${tz}
        
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['time']}  ${st}-${et}
        Should Be Equal As Strings  ${resp.json()[0]['availableSlots'][${index}]['noOfAvailbleSlots']}  ${parallel}
        # Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['capacity']}   ${consumerParallel}
        IF  '${active_slot}' == 'True'
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[0]}
        ELSE
            Should Be Equal As Strings   ${resp.json()[0]['availableSlots'][${index}]['active']}      ${bool[1]}
        END
        Set Test Variable  ${st}  ${et}
    END