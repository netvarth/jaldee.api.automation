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
JD-TC-Get schedule By loc and service-1
	[Documentation]  Get schedule for given location and service
	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable   ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    clear_service   ${PUSERNAME210}
    clear_location  ${PUSERNAME210}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME210}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
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
    

JD-TC-Get schedule By loc and service-2
	[Documentation]  Get schedule for multiple locations

	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME210}
    # clear_location  ${PUSERNAME210}
    clear_service   ${PUSERNAME210}
    clear_location  ${PUSERNAME210}

    ${lid}=  Create Sample Location
	${lid1}=  Create Sample Location
    clear_appt_schedule   ${PUSERNAME210}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

	${schedule_name1}=  FakerLibrary.bs
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime1}  ${delta1}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
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

	${resp}=  Get Appointment Schedule by location and service  ${lid1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name1}  id=${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}

JD-TC-Get schedule By loc and service-3
	[Documentation]  Get schedule for multiple services
	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME210}
    clear_location  ${PUSERNAME210}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME210}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    
	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
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
    

	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id1}
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
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}

JD-TC-Get schedule By loc and service-4
	[Documentation]  Get schedule for multiple services in multiple locations
	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME210}
    # clear_location  ${PUSERNAME210}
    clear_service   ${PUSERNAME210}
    clear_location  ${PUSERNAME210}

    ${lid}=  Create Sample Location
	Set Suite Variable    ${lid}
	${lid1}=  Create Sample Location
	Set Suite Variable    ${lid1}
    clear_appt_schedule   ${PUSERNAME210}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
	Set Suite Variable    ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
	Set Suite Variable    ${s_id1}
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

	${schedule_name1}=  FakerLibrary.bs
	${delta1}=  FakerLibrary.Random Int  min=10  max=60
	${eTime2}=  add_two   ${sTime1}  ${delta1}
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
	${duration}=  FakerLibrary.Random Int  min=1  max=${delta1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime2}  ${parallel1}    ${parallel1}  ${lid1}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}
    
	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
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
    

	${resp}=  Get Appointment Schedule by location and service  ${lid1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  name=${schedule_name1}  id=${sch_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}

JD-TC-Get schedule By loc and service-UH1
	[Documentation]  Get schedule for another providers location

	${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

	${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=  Get Appointment Schedule by location and service  ${lid1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
	Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-Get schedule By loc and service-UH2
	[Documentation]  Get schedule for another providers service

	${resp}=  Encrypted Provider Login  ${PUSERNAME211}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sid1}   ${resp.json()[0]['id']}

	${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
	Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-Get schedule By loc and service-UH3
	[Documentation]  Get schedule without login

	${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
	Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"