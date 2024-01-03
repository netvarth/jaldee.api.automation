*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        NotificationSettings
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***
${Zero_person_ahead}   0
${One_person_ahead}    1
${self}         0
${globaluser}         0



*** Test Cases ***

JD-TC-AppointmentReminder-1

    [Documentation]   Provider setting consumer notification settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_consumer_notification_settings  ${PUSERNAME45}
    clear_service   ${PUSERNAME45}
    clear_multilocation  ${PUSERNAME45}    
    clear_appt_schedule   ${PUSERNAME45}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${businessName}  ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${reminder_time}=  Random Int   min=5   max=5

    ${resp}=  Create Appointment Reminder Settings  ${NotificationResourceType[1]}  ${EventType[11]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  
                                  ...   ${msg}  ${reminder_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}       ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}          ${EventType[11]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}              ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}      ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['time']}               ${reminder_time}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  add_timezone_time  ${tz}  0  10  
    ${eTime1}=  add_timezone_time  ${tz}  1  15  

    
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=5  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
    Set Suite Variable  ${userName}  ${resp.json()['userName']}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Reminder
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date}=  Convert Date  ${DAY1}  result_format="%a, %d %b %Y"
    ${date}=         evaluate       '${date}'.replace('"','')
    ${converted_slot1}=  convert_slot_12hr  ${slot1} 
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[consumer] 	${userName}
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[appttime] 	First
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[provider] 	${businessName}
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[time] 	${converted_slot1}
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[date] 	${date}
    ${appmntReminder_Consumer_APP} = 	Replace String 	${appmntReminder_Consumer_APP} 	[service] 	${SERVICE1}
    ${service_format_date}=   DateTime.Convert Date    ${DAY1}   result_format="%a, %d %b %Y"
    ${service_format}=  Set Variable  ${SERVICE1}${SPACE}on${SPACE}"${service_format_date}"
    
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${globaluser}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['userType']}  ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}  ${appmntReminder_Consumer_APP}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountName']}  ${businessName}
    Should Be Equal As Strings  ${resp.json()[0]['service']}  ${service_format}
    Should Be Equal As Strings  ${resp.json()[0]['read']}  ${boolean[0]}
    Should Be Equal As Strings  ${resp.json()[0]['timeZone']}  ${tz}
 