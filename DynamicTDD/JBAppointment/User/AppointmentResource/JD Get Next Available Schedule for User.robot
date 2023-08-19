*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  NextAvailableSchedule
Library     Collections
Library     String
Library     json
Library     requests
Library     FakerLibrary
Library     /ebs/TDD/db.py
Resource    /ebs/TDD/ProviderKeywords.robot
Resource    /ebs/TDD/ConsumerKeywords.robot
Resource    /ebs/TDD/SuperAdminKeywords.robot
Variables   /ebs/TDD/varfiles/providers.py
Variables   /ebs/TDD/varfiles/musers.py
Variables   /ebs/TDD/varfiles/consumerlist.py
Variables   /ebs/TDD/varfiles/consumermail.py

*** Variables ***
@{countryCode}   91  +91  48 
@{emptylist}

*** Test Cases ***  

JD-TC-NextAvailableSchedule for User-1

    [Documentation]   Get next available schedule for user when there is only one schedule

    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME57}
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${MUSERNAME57}
    clear_appt_schedule   ${MUSERNAME57}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
       
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME57}'
            clear_users  ${user_phone}
        END
    END

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH0}
    Set Suite Variable  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH0}
    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  02s
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}      ${u_id}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    # Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.${test_mail}  state=${state}  deptId=${dep_id} 

    ${resp}=  SendProviderResetMail   ${PUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${eTime1}=  add_time  3  15
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}  ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()}"  availableSlots
    # ${sch_length}=  get_slot_length  ${delta}  ${duration}
    # ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']['availableSlots']}
    # Should Be Equal As Integers  ${sLength}  ${sch_length}


JD-TC-NextAvailableSchedule for User-2
    [Documentation]   Get next available schedule for user when there are more than 1 schedule

    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME57}

    clear_service   ${MUSERNAME57}
    clear_appt_schedule   ${MUSERNAME57}
    clear_service   ${PUSERPH0}
    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}      ${u_id}
    # Verify Response  ${resp}  id=${u_id}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  5
    # ${sTime1}=  db.get_time
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  add_two  ${eTime1}  5
    ${delta2}=  FakerLibrary.Random Int  min=40  max=80
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/5}
    ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${parallel2}  ${lid}  ${duration2}  ${bool2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${sch_id1}   name=${schedule_name1}   apptState=${Qstate[0]}
    Verify Response List  ${resp}  0  id=${sch_id2}   name=${schedule_name2}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name2}  timeDuration=${duration2}  apptState=${Qstate[0]}  parallelServing=${parallel2}  batchEnable=${bool2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

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
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool1}
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

    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME57}

    clear_service   ${MUSERNAME57}
    clear_appt_schedule   ${MUSERNAME57}
    clear_service   ${PUSERPH0}
    clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}      ${u_id}
    # Verify Response  ${resp}  id=${u_id}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${time_now}=   db.get_time
    ${sTime1}=  sub_two  ${time_now}   ${delta1+5}
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}      ${parallel1}  ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${delta2}=  FakerLibrary.Random Int  min=40  max=80
    ${sTime2}=  add_time  0  5
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval2}=  Convert To Integer   ${delta2/5}
        ${duration2}=  FakerLibrary.Random Int  min=1  max=${maxval2}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${parallel2}  ${lid}  ${duration2}  ${bool2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${sch_id1}   name=${schedule_name1}   apptState=${Qstate[0]}
    Verify Response List  ${resp}  0  id=${sch_id2}   name=${schedule_name2}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name2}  timeDuration=${duration2}  apptState=${Qstate[0]}  parallelServing=${parallel2}  batchEnable=${bool2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}  ${schedule_name2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel2}
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()}"  availableSlots
    ${sch_length}=  get_slot_length  ${delta2}  ${duration2}
    ${sLength}=  Get Length  ${resp.json()[0]['availableSlots']['availableSlots']}
    Should Be Equal As Integers  ${sLength}  ${sch_length}

JD-TC-NextAvailableSchedule for User-4
    [Documentation]   Get next available schedule for multiple users.

    ${resp}=  Provider Login  ${MUSERNAME53}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${MUSERNAME53}
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${MUSERNAME53}
    clear_appt_schedule   ${MUSERNAME53}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH1}
    Set Test Variable  ${PUSERPH1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    clear_service   ${PUSERPH1}
    clear_appt_schedule   ${PUSERPH1}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}      ${u_id}
    # Should Be Equal As Strings  ${resp.json()['city']}      ${city}    ignore_case=True
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH1}.${test_mail}   state=${state}  deptId=${dep_id}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_time  0  5
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${MUSERNAME59}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME59}

    clear_service   ${MUSERNAME59}
    clear_appt_schedule   ${MUSERNAME59}
    clear_service   ${MUSERNAME59}
    clear_appt_schedule   ${MUSERNAME59}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    # Set Test variable  ${lic2}  ${highest_package[0]}
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id1}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH2}
    Set Test Variable  ${PUSERPH2}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    clear_service   ${PUSERPH2}
    clear_appt_schedule   ${PUSERPH2}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH2}  ${dep_id1}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    # sleep  3s
    # ${resp}=    Get Departments
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id1}   ${resp.json()[0]['id']}

    sleep  2s
    ${resp}=  Get Users By Department  ${dep_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  mobileNo=${PUSERPH2}  deptId=${dep_id1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    FakerLibrary.Word
    ${s_id1}=  Create Sample Service For User  ${SERVICE2}  ${dep_id1}  ${u_id1}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_time  0  15
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${time_now}=   db.get_time
    ${sTime1}=  add_two  ${time_now}   ${delta1+5}
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
        ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool2}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}  ${lid1}  ${duration1}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name1}  timeDuration=${duration1}  apptState=${Qstate[0]}  parallelServing=${parallel1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

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
    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool1}
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
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['timeDuration']}   ${duration1}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['parallelServing']}   ${parallel1}
    # Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['batchEnable']}   ${bool2}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['isCheckinAllowed']}   ${bool[1]}
    Should Contain  "${resp.json()[1]}"  availableSlots
    ${sch_length1}=  get_slot_length  ${delta1}  ${duration1}
    ${sLength1}=  Get Length  ${resp.json()[1]['availableSlots']['availableSlots']}
    Should Be Equal As Integers  ${sLength1}  ${sch_length1}

JD-TC-NextAvailableSchedule for User-5
    [Documentation]   Get next available schedule without login
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${u_id}   ${resp.json()[3]['id']}

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
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Contain  "${resp.json()[0]}"  availableSlots

JD-TC-NextAvailableSchedule for User-6
    [Documentation]   Get next available schedule with consumer login
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Contain  "${resp.json()[0]}"  availableSlots

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-NextAvailableSchedule for User-UH1
    [Documentation]   Get next available schedule for user with invalid account id
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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
    [Documentation]   Get next available schedule for user with Empty user id
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${lid}  ${EMPTY}

    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH5
    [Documentation]   Get next available schedule for user with Empty location id
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${pid}   ${EMPTY}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-NextAvailableSchedule for User-UH6
    [Documentation]   Get next available schedule for user with Empty account id
    ${pid}=  get_acc_id  ${MUSERNAME57}
    ${resp}=  Provider Login  ${MUSERNAME57}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

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

    ${resp}=    Get NextAvailableSchedule By Provider Location and User    ${EMPTY}   ${lid}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

