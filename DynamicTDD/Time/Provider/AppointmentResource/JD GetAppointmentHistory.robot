*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment History
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

${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
${self}   0

*** Test Cases ***   

JD-TC-GetAppointmentHistory-1

    [Documentation]   Get Appointment History  and History count

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${accId}=  get_acc_id  ${PUSERNAME140}

    Set Suite Variable  ${accId}
    clear_service   ${PUSERNAME140}
    clear_location  ${PUSERNAME140}
   
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}

    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}

    ${lid1}=  Create Sample Location  
    Set Suite Variable    ${lid1}

    ${resp}=   Get Location By Id   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${today}=   db.get_date_by_timezone  ${tz}
    
    ${cur_date}=   change_system_date   -5
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${DAY2}=  db.add_timezone_date  ${tz}  2     
    Set Suite Variable  ${DAY2} 
        
       
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}


    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId    ${sch_id}    ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
    
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
       IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}
  
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME16}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

       
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable     ${encId1}     ${resp.json()['appointmentEncId']}

    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${cname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${cname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

    
    ${resp}=   Get Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   1  
    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-2
    [Documentation]    Get provider's appointments history with appointment status conform

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-3

    [Documentation]    Get provider's appointments history for service  ${SERVICE1} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   service-eq=${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  

JD-TC-GetAppointmentHistory-4
    
    [Documentation]  Get provider's appointments history for consumers with firstname  ${cname1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  firstName-eq=${cname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   firstName-eq=${cname1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  

JD-TC-GetAppointmentHistory-5

    [Documentation]   Get provider's appointments history for consumers with lastname  ${cname2}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  lastName-eq=${cname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   lastName-eq=${cname2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-6

    [Documentation]    Get provider's appointments history in schedule ${sch_id1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  schedule-eq=${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   schedule-eq=${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-7

    [Documentation]   Get provider's appointments history   appointment taken by consumer(apptBy)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History   apptBy-eq=CONSUMER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   apptBy-eq=CONSUMER
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  

JD-TC-GetAppointmentHistory-8

    [Documentation]   Get provider's appointments history   where appointment slot is ${slot1} (apptTime)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   apptTime-eq=${slot1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-9

    [Documentation]   Get provider's appointments history   where paymentStatus is NotPaid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   paymentStatus-eq=${paymentStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1  


JD-TC-GetAppointmentHistory-10

    [Documentation]   Get provider's appointments history   where location is  ${lid1}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  location-eq=${lid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
    Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
    Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
    Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
    Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

    ${resp}=  Get Appointment History Count   location-eq=${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}   1 

# JD-TC-GetAppointmentHistory-11

#     [Documentation]   Get provider's appointments history   for time apptstartTime
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Appointments History  apptstartTime-eq=${sTime1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['id']}   ${cid}
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['id']}   ${cid}
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['firstName']}   ${cname1}
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['userProfile']['lastName']}   ${cname2}
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['id']}   ${cid}
#     Should Be Equal As Strings   ${resp.json()[0]['consumer']['createdBy']['userName']}   ${username}
#     Should Be Equal As Strings   ${resp.json()[0]['service']['id']}  ${s_id1}
#     Should Be Equal As Strings   ${resp.json()[0]['service']['name']}   ${SERVICE1}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['id']}    ${sch_id}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['name']}   ${schedule_name}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['recurringType']}   ${recurringtype[1]}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['startDate']}    ${DAY1}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['terminator']['endDate']}    ${DAY2}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['sTime']}    ${sTime1}
#     Should Be Equal As Strings   ${resp.json()[0]['schedule']['apptSchedule']['timeSlots'][0]['eTime']}    ${eTime1}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['firstName']}    ${cname1}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['lastName']}    ${cname2}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['userName']}    ${username}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtFor'][0]['apptTime']}    ${slot1}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtDate']}   ${DAY1}
#     Should Be Equal As Strings   ${resp.json()[0]['appmtTime']}   ${slot1}
#     Should Be Equal As Strings   ${resp.json()[0]['providerAccount']['id']}   ${accId}
#     Should Be Equal As Strings   ${resp.json()[0]['location']['id']}   ${lid1}
#     Should Be Equal As Strings   ${resp.json()[0]['phoneNumber']}   ${primaryPhoneNumber}

#     ${resp}=  Get Appointment History Count   apptstartTime-eq=${sTime1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()}   1



JD-TC-GetAppointmentHistory-12

    [Documentation]   Get provider's appointments history for gender male and female

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${gens}=   Create List
    ${resp}=  Get Consumer By Id  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To List   ${gens}   ${resp.json()['userProfile']['gender']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${count_male}=  Get Match Count  ${gens}  ${Genderlist[1]}
    ${count_female}=  Get Match Count  ${gens}  ${Genderlist[0]}

    ${resp}=   Get Appointments History  gender-eq=${Genderlist[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_male} 
    
    ${resp}=  Get Appointment History Count   gender-eq=${Genderlist[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_male}

    ${resp}=   Get Appointments History  gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length   ${resp.json()}
    Should Be Equal As Strings  ${len}  ${count_female} 
    
    ${resp}=  Get Appointment History Count   gender-eq=${Genderlist[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${count_female}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-GetAppointmentHistory-13

    [Documentation]   Check appointment history count
    ${cur_date}=   change_system_date   -5
    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId    ${sch_id}    ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
    
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
       IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}
       
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME11}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment History Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   2 

    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   2 



JD-TC-GetAppointmentHistory-14 

    [Documentation]  Get provider's appointments history with appointment status cancelled
    ${cur_date}=   change_system_date   -5
    ${resp}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId    ${sch_id}    ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
       IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME8}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id3}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable     ${encId1}     ${resp.json()['appointmentEncId']}

    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}
   
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid2}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[4]}
   
    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[4]}
   
    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[4]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-GetAppointmentHistory-15

    [Documentation]   Get provider's appointments history with appointment status Rejected

    ${cur_date}=   change_system_date   -5
    ${resp}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId    ${sch_id}    ${accId} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['scheduleId']}   ${sch_id}
    Should Be Equal As Strings   ${resp.json()['scheduleName']}   ${schedule_name}
   
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
       IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id3}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable     ${encId1}     ${resp.json()['appointmentEncId']}
    Verify Response   ${resp}  uid=${apptid3}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[1]}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Reject Appointment  ${apptid3}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid3}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId1}  apptStatus=${apptStatus[5]}
   
    ${resp}=  Get Appointment Status   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-GetAppointmentHistory-UH1

    [Documentation]  Consumer try to get Appointment History 
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetAppointmentHistory-UH2

    [Documentation]  Consumer try to get Appintment History count
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Appointment History Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-GetAppointmentHistory-UH3

    [Documentation]   Get Appointment History without login
    ${resp}=   Get Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetAppointmentHistory-UH4

    [Documentation]  Get Appointment History count without login
    ${resp}=  Get Appointment History Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"


