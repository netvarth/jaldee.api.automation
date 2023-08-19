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

*** Test Cases ***  
JD-TC-NextAvailableSchedule consumer -1
    [Documentation]   Get next available schedule for user when there is only one schedule

    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME58}
    Set Suite Variable  ${pid}
    
    ${highest_package}=   get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=    Change License Package   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${MUSERNAME58}
    clear_appt_schedule   ${MUSERNAME58}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH9}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH9}
    Set Suite Variable  ${PUSERPH9}
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
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable   ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable   ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH9}
    clear_appt_schedule   ${PUSERPH9}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH9}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH9}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH9}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH9}.${test_mail}   deptId=${dep_id} 

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}   ${parallel}    ${lid}  ${duration}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool0}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}


   
    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid}  ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                                             ${u_id}
  
  #  Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}   ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool0}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
   #  Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}
   

JD-TC-NextAvailableSchedule consumer -2
    [Documentation]   Get next available schedule  when there more than one schedule

    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME58}
    
    clear_service   ${MUSERNAME58}
    clear_appt_schedule   ${MUSERNAME58}
    clear_service   ${PUSERPH9}
    clear_appt_schedule   ${PUSERPH9}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
   
    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
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
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}    ${lid}  ${duration1}  ${bool1}  ${s_id}
    Log   ${resp.content}
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
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${parallel2}    ${lid}  ${duration2}  ${bool2}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  1  id=${sch_id1}   name=${schedule_name1}   apptState=${Qstate[0]}
    Verify Response List  ${resp}  0  id=${sch_id2}   name=${schedule_name2}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log   ${resp.content}
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
    Log   ${resp.content}
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

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}


   
    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid}  ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                                             ${u_id}
  
    #Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id1}
  
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool1}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    


JD-TC-NextAvailableSchedule consumer -3
    [Documentation]   Get next available schedule by provider login
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}


    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  5
     ${sTime1}=  db.get_time
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval1}=  Convert To Integer   ${delta1/5}
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${maxval1}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${parallel1}    ${lid}  ${duration1}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}


    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name1}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    
    
    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid}  ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
    Should Contain  "${resp.json()[0]}"  availableSlots


JD-TC-NextAvailableSchedule consumer -4
    [Documentation]   Get next available schedule wthiout  login
    # ${pid}=  get_acc_id  ${MUSERNAME58}

    ${resp}=    Get NextAvailableSchedule appt consumer    ${pid}    ${lid}   ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}

    # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['name']}    ${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['location']['id']}    ${lid}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['startDate']}     ${DAY1}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['terminator']['endDate']}     ${DAY2}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['sTime']}     ${sTime1}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptSchedule']['timeSlots'][0]['eTime']}     ${eTime1}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['apptState']}   ${Qstate[0]}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['services'][0]['id']}   ${s_id}
   # Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['timeDuration']}   ${duration}
    #Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['parallelServing']}   ${parallel}
    #Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['batchEnable']}   ${bool0}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['todayAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['futureAppt']}  ${bool[1]}
    #Should Be Equal As Strings  ${resp.json()[0]['availableSchedule']['availableDate']}     ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[1]}
    #Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ACCOUNT_NOT_EXIST}
   # Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
 


JD-TC-NextAvailableSchedule consumer -UH1
    [Documentation]   Get next available schedule for user with invalid account id
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${rand_pid}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${rand_pid}   ${lid}  ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}


JD-TC-NextAvailableSchedule consumer -UH2
    [Documentation]   Get next available schedule for user with invalid location id
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

     ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${rand_lid}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${rand_lid}   ${u_id}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${u_id}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}


JD-TC-NextAvailableSchedule consumer -UH3
    [Documentation]   Get next available schedule for user with invalid user id
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

     ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${rand_u}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid}  ${rand_u}               
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}   ${rand_u}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ACCOUNT_NOT_EXIST}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}

JD-TC-NextAvailableSchedule consumer -UH4
    [Documentation]   Get next available schedule ,to gave another provider location 
    

    ${resp}=  Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${MUSERNAME48}
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${MUSERNAME48}
    clear_appt_schedule   ${MUSERNAME48}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH11}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH11}
    Set Suite Variable  ${PUSERPH11}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    # ${pin1}=  get_pincode
  
    # ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable   ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable   ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH11}
    clear_appt_schedule   ${PUSERPH11}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH11}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH11}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    sleep  2s
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH11}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH11}.${test_mail}  deptId=${dep_id} 

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${SERVICE2}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE2}  ${dep_id}  ${u_id1}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid1}  ${duration}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

     ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #${rand_u}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid1}   ${u_id}             
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
    #Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}


JD-TC-NextAvailableSchedule consumer -UH5
    [Documentation]   Get next available schedule , another provider userid


    ${resp}=  Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${MUSERNAME48}
    
  #  ${highest_package}=  get_highest_license_pkg
  #  Log  ${highest_package}
   # Set Suite variable  ${lic2}  ${highest_package[0]}

  #  ${resp}=   Change License Package  ${highest_package[0]}
  #  Log  ${resp.content}
  #  Should Be Equal As Strings    ${resp.status_code}   200

   # ${resp}=   Get License UsageInfo 
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200

    #clear_service   ${MUSERNAME48}
  #  clear_appt_schedule   ${MUSERNAME48}
    
  #  ${resp2}=   Get Business Profile
   # Log  ${resp2.json()}
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

   # ${resp}=  View Waitlist Settings
   # Log   ${resp.content}
  #  Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
   # Run Keyword If  '${resp}' != '${None}'   Log   ${resp.content}
   
  #  ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH11}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH11}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Set Suite Variable  ${u_id1}  ${resp.json()}

   
    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id1}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME48}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id1}   ${resp.json()[${i}]['id']}
        END
    END

    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

   
    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    #${rand_u}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}     ${lid}   ${u_id1}            
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ONLINE_APPT_NOT_AVAILABLE}
   

JD-TC-NextAvailableSchedule consumer -UH6
    [Documentation]   Get next available schedule another provider account id


    ${resp}=  Provider Login  ${MUSERNAME48}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${MUSERNAME48}
    
  #  ${highest_package}=  get_highest_license_pkg
  #  Log  ${highest_package}
   # Set Suite variable  ${lic2}  ${highest_package[0]}

  #  ${resp}=   Change License Package  ${highest_package[0]}
  #  Log  ${resp.content}
  #  Should Be Equal As Strings    ${resp.status_code}   200

   # ${resp}=   Get License UsageInfo 
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200

    #clear_service   ${MUSERNAME48}
  #  clear_appt_schedule   ${MUSERNAME48}
    
  #  ${resp2}=   Get Business Profile
   # Log  ${resp2.json()}
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

   # ${resp}=  View Waitlist Settings
   # Log   ${resp.content}
  #  Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
   # Run Keyword If  '${resp}' != '${None}'   Log   ${resp.content}
   
  #  ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH11}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH11}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Set Suite Variable  ${u_id1}  ${resp.json()}

   
    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id1}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME48}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id1}   ${resp.json()[${i}]['id']}
        END
    END

    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable   ${u_id}   ${resp.json()[0]['id']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['mobileNo']}' == '${MUSERNAME58}' 
            Set Test Variable   ${u0_id}   ${resp.json()[${i}]['id']}
        ELSE
            Set Test Variable   ${u_id}   ${resp.json()[${i}]['id']}
        END
    END

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${sch_id}   ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #${rand_u}=  FakerLibrary.Random Int  min=1000  max=10000

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid1}   ${lid}       ${u_id}            
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  #  Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_NOT_FOUND}


JD-TC-NextAvailableSchedule consumer -UH7
    [Documentation]   Get next available schedule  with same provider another location without appt
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dep_name2}=  FakerLibrary.bs
    ${dep_code2}=   Random Int  min=100   max=999
    ${dep_desc2}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id2}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH9}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH9}
    Set Suite Variable  ${PUSERPH9}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    # ${pin1}=  get_pincode
    
    # ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable   ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable   ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH9}
    clear_appt_schedule   ${PUSERPH9}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH9}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH9}  ${dep_id2}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  #  Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH9}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH9}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id} 

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}


    ${lid}=  Create Sample Location
    ${lid1}=  Create Sample Location

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id2}  ${u_id1}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid1}  ${duration}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool0}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}


    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid1}  ${u_id}            
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  #  Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${ONLINE_APPT_NOT_AVAILABLE}

   
   
   

JD-TC-NextAvailableSchedule consumer -UH8
    [Documentation]   Get next available schedule  with same provider another location disable
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dep_name2}=  FakerLibrary.bs
    ${dep_code2}=   Random Int  min=100   max=999
    ${dep_desc2}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id2}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH9}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH9}
    Set Suite Variable  ${PUSERPH9}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    # ${pin1}=  get_pincode
  
    # ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable   ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable   ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    clear_service   ${PUSERPH9}
    clear_appt_schedule   ${PUSERPH9}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH9}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH9}  ${dep_id2}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  #  Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH9}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH9}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id} 

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${lid}=  Create Sample Location
    ${lid1}=  Create Sample Location

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id2}  ${u_id1}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid1}  ${duration}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool0}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${resp}=  Disable Location  ${lid1}
    Log   ${resp.content}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid1}  ${u_id}            
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  #  Should Be Equal As Strings  ${resp.json()[0]['isCheckinAllowed']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message']}   ${LOCATION_DISABLED}


JD-TC-NextAvailableSchedule consumer -5
    [Documentation]   Get next available schedule  with same provider another location and  another userid
    ${pid}=  get_acc_id  ${MUSERNAME58}
    ${resp}=  Provider Login  ${MUSERNAME58}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dep_name2}=  FakerLibrary.bs
    ${dep_code2}=   Random Int  min=100   max=999
    ${dep_desc2}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id2}  ${resp.json()}

    ${dep_name3}=  FakerLibrary.bs
    ${dep_code3}=   Random Int  min=100   max=999
    ${dep_desc3}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc3} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()}

   
    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH9}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH9}
    Set Suite Variable  ${PUSERPH9}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    ${pin1}=  get_pincode
    

    FOR  ${p}  IN RANGE  6
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH13}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH13}
    Set Suite Variable  ${PUSERPH13}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${location1}=  FakerLibrary.city
    ${state}=  FakerLibrary.state
    # ${pin1}=  get_pincode
    
    # ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable   ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable   ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH13}
    clear_appt_schedule   ${PUSERPH13}

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH13}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH13}  ${dep_id3}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  #  Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH9}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH9}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id} 
     
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH9}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERPH9}  ${dep_id2}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
  
    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid1}   ${resp.json()[0]['id']}

    ${lid}=   Create Sample Location
    ${lid1}=  Create Sample Location

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id3}  ${u_id2}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  add_time  0  20
    ${delta2}=  FakerLibrary.Random Int  min=20  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration2}=  FakerLibrary.Random Int  min=1  max=${delta2}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id2}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${parallel}    ${lid1}  ${duration2}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name2}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response  ${resp}  name=${schedule_name}  timeDuration=${duration}  apptState=${Qstate[0]}  parallelServing=${parallel}  batchEnable=${bool0}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    

    ${DAY1}=  get_date
    ${DAY2}=  add_date  15
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration1}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool0}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}    ${lid1}  ${duration1}  ${bool0}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id1}   name=${schedule_name1}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    
   # ${resp}=  Disable Location  ${lid1}
    #Log   ${resp.content}

    ${resp}=  Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
   # Log   ${resp.content}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Verify Response   ${resp}    appmtTime=${slot1}  apptStatus=${apptStatus[2]}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}  ${fname}
   # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}

    ${resp}=    Get NextAvailableSchedule appt consumer   ${pid}   ${lid1}  ${u_id2}            
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
   
