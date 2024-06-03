*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Vacation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py



*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789


***Test Cases***

JD-TC-CreateVacation-1
    [Documentation]  Creating a Vacation when Waitlist is Enabled
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${PUSERNAME_E1}=  Evaluate  ${PUSERNAME}+778805577
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E1}${\n}
    Set Suite Variable  ${PUSERNAME_E1}
    ${id}=  get_id  ${PUSERNAME_E1}
    ${bs}=  FakerLibrary.bs


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERNAME_E1}+1000880000
    ${ph2}=  Evaluate  ${PUSERNAME_E1}+2000880000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url

    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  4  30  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep   01s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${ph1}  ${countryCodes[0]}  ${ph1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    #${resp}=  Waitlist Status    ${toggle[0]}
    #Log  ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}  
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v1_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}   description=${desc} 
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-2
    [Documentation]  Creating a Vacation when Appointment is Enable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid_B15}=  get_acc_id  ${PUSERNAME_E1}
    Set Suite variable  ${pid_B15}

    
    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}   appointment=${bool[1]}   

    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=60  max=120
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}   ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    # ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${uname}  ${resp.json()['userName']}
    # ${JC_id01}=  get_id  ${CUSERNAME5} 
    
    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid_B15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
        #     Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        # END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${p}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot1}   ${slots[${p}]}

    # ${q}=  Random Int  max=${num_slots-2}
    # Set Test Variable   ${slot2}   ${slots[${q}]}

    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}

    # ${pcid1}=  get_id  ${CUSERNAME5}
    # ${appt_for1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}  
    # ${apptfor1}=   Create List  ${appt_for1}
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For User    ${pid_B15}  ${s_id}  ${sch_id}  ${CUR_DAY}  ${cnote}  ${u_id}   ${apptfor1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${apptid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${apptid01}  ${apptid[0]}
    # # sleep  02s 

    # ${resp}=   Get consumer Appointment By Id   ${pid_B15}  ${apptid01}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule by location and service  ${lid}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_time}=  add_timezone_time  ${tz}   1  20
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  0  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v2_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}   description=${desc} 
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-CreateVacation-3
    [Documentation]    Overlapping time solts when Waitlist and Appointment is Enable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}  appointment=${bool[1]}


    ${start_time}=  add_timezone_time  ${tz}  0  20  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  50   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v3_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}   description=${desc}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-4
    [Documentation]    Using Multiple Appointment solts when Appointment is Enable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${number}=  Random Int  min=60000  max=899900
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
   
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id04}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id04}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}   appointment=${bool[1]}

    

    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${sTime1}=  add_timezone_time  ${tz}  0  20  
    Set Suite Variable   ${start_time}
    ${eTime1}=    add_timezone_time  ${tz}  2  40   
    Set Suite Variable    ${end_time}
    ${delta}=  FakerLibrary.Random Int  min=10  max=45
    Set Suite Variable  ${delta}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id2}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id01}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}
   
    
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id2}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id02}  ${resp.json()}

    ${start_time}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  30   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id04}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v4_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation     ${p1_id04}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}   description=${desc}
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY4}=  db.add_timezone_date  ${tz}  4   
    ${resp}=  Get Appointment Schedule by date  ${DAY4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
JD-TC-CreateVacation-9
    [Documentation]     Using Multiple Appointment slots and given the future date to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}
    
    ${DAY4}=  db.add_timezone_date  ${tz}  4   
    ${resp}=  Get Appointment Schedule by date  ${DAY4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_time}=  add_timezone_time  ${tz}  0  20  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  30   
    Set Suite Variable    ${end_time}    
    Set Suite Variable    ${DAY4}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id04}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY4}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v5_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation    ${p1_id04}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v5_id}    description=${desc}
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY4}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY4}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v5_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-CreateVacation-5
    [Documentation]  Creating a Vacation, Using Multiple Queues when Waitlist is Enable 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${number}=  Random Int  min=4000  max=5999
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+${number}

    clear_users  ${PUSERNAME_U4}
    Set Suite Variable  ${PUSERNAME_U4}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U4}  ${countryCodes[0]}  ${PUSERNAME_U4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id4}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id05}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id05}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}   0  5
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}   1  55
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  00  
    Set Suite Variable   ${eTime2}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}
    ${SERVICE6}=   FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id6}  ${resp.json()}

    ${SERVICE7}=   FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE7}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id7}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id4}  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id01}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id4}  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id02}  ${resp.json()}

    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Appointment Status   ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    ${start_time}=  add_timezone_time  ${tz}  0  20  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  40   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v6_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation    ${p1_id05}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateVacation-6
    [Documentation]    Waitlist is Enable and given the future date to create vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    ${start_time}=  add_timezone_time  ${tz}  0  20  
    ${end_time}=    add_timezone_time  ${tz}  2  40   
    ${DAY2}=  db.add_timezone_date  ${tz}  2        
    Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v7_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${p1_id05}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}  description=${desc}      
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-CreateVacation-7
    [Documentation]    Waitlist is Enable and given the future date to create vacation (Set StartTime as todays Past Time)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name1}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}
    #${resp}=  Waitlist Status    ${toggle[0]}
    #Log  ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    # ${start_time}=  add_timezone_time  ${tz}  2  00  
    # Set StartTime as todays Past Time To create Vacation
    ${start_time}=  db.subtract_timezone_time  ${tz}  1  10
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    ${DAY2}=  db.add_timezone_date  ${tz}  3        
    Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v8_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-8
    [Documentation]  Appointment is Enable and given the future date to create vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}

    ${start_time}=  db.subtract_timezone_time  ${tz}  1  10
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    ${DAY3}=  db.add_timezone_date  ${tz}  1        
    Set Suite Variable  ${DAY3}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY3}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v9_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc} 
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY3}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY3}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-10
    [Documentation]    Multiple Appointment Solts and Appointment is Enable and given the future date to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id01}  ${resp.json()}
    ${number}=  Random Int  min=3000  max=3999
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id01}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id09}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id09}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}   appointment=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=30  max=45
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id2}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id01}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Accountsettings  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}
    
    ${sTime1}=  add_timezone_time  ${tz}  1  10
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=30  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id2}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id02}  ${resp.json()}
    
    ${start_time}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  30   
    Set Suite Variable    ${end_time}
    ${DAY5}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY5}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id2}  ${recurringtype[1]}  ${list}  ${DAY5}  ${DAY5}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v10_id}    ${resp.json()['holidayId']}
    


    ${resp}=   Get Vacation  ${u_id2}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc}  
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY5}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY5}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateVacation-11
    [Documentation]    Waitlist and Appointment is Enable and given the future date to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=600   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Set Suite Variable  ${dep_id}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${number}=  Random Int  min=2000  max=2999

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id10}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id10}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}   0  10
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
    # ${lid05}=  Create Sample Location
    # Set Suite Variable  ${lid05}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}  appointment=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[1]}

    ${start_time}=  add_timezone_time  ${tz}  0  20  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  50   
    Set Suite Variable    ${end_time}
    ${DAY6}=  db.add_timezone_date  ${tz}  6        
    Set Suite Variable  ${DAY6}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v11_id}    ${resp.json()['holidayId']}
     


    ${resp}=   Get Vacation   ${p1_id10}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}   description=${desc}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY6}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY6}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    # ${resp}=  Delete Vacation  ${v_id} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-12
    [Documentation]  Creating a Vacation with out of timeframe schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  4  15  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}   4  35 
    Set Suite Variable    ${end_time}
    ${DAY2}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable    ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v15_id}    ${resp.json()['holidayId']}
     
    ${resp}=  Get Vacation By Id  ${v15_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    id=${v15_id}   description=${desc}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_CREATE_TIME}"
JD-TC-CreateVacation-UH1
    [Documentation]  Create an already existing Vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${P_Sector}   ${resp.json()['sector']}

    ${start_time}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  30   
    Set Suite Variable    ${end_time}
    ${DAY6}=  db.add_timezone_date  ${tz}  6  
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH4
    [Documentation]   Provider ID is Empty when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    #${DAY2}=  db.add_timezone_date  ${tz}  2        
    #Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${CUR_DAY}  ${desc}  ${Empty}
    ${resp}=  Create Vacation  ${desc}  ${NULL}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    Provider Not Found
    # Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}" 

JD-TC-CreateVacation-UH5
    [Documentation]   Giving Invalid Provider ID when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    #${DAY2}=  db.add_timezone_date  ${tz}  2        
    #Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${p1_id10}=   Random Int   min=100000   max=999999
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${CUR_DAY}  ${desc}  ${p1_id10}
     ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found 


JD-TC-CreateVacation-UH6
    [Documentation]  create a past date  vacation for a valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}

    ${PAST_DAY}=  db.add_timezone_date  ${tz}  -1
    Set Suite Variable   ${PAST_DAY}
    
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${PAST_DAY}  ${desc}  ${p1_id10}
     ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${PAST_DAY}  ${PAST_DAY}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_START_DATE_INCORRECT}



JD-TC-CreateVacation-UH7
    [Documentation]  create  an overlapping end time for an existing vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[1]}

    ${resp}=  Get Vacation By Id  ${v11_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_time}=  add_timezone_time  ${tz}   1  40
    ${end_time}=    add_timezone_time  ${tz}  2  30  
    ${DAY6}=  db.add_timezone_date  ${tz}  6  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH8
    [Documentation]  create  an overlapping start time for an existing vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[1]}

    ${start_time}=  db.subtract_timezone_time  ${tz}  0  30
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    ${DAY6}=  db.add_timezone_date  ${tz}  6        
    ${desc}=    FakerLibrary.name
     ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH9
    [Documentation]  create a vacation with starttime less than already existing  and endtime greater than existing one

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[1]}

    ${start_time}=  db.subtract_timezone_time  ${tz}  0  30
    ${end_time}=    add_timezone_time  ${tz}  2  00  
    ${DAY6}=  db.add_timezone_date  ${tz}  6  
    ${desc}=    FakerLibrary.name
     ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}



JD-TC-CreateVacation-UH10
    [Documentation]  create a past time  vacation for a valid provider on current day

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${start_time}=  db.subtract_timezone_time  ${tz}  0  05
    ${end_time}=    add_timezone_time  ${tz}  1  05  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_START_TIME_INCORRECT}
    # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_CREATE_TIME}"



JD-TC-CreateVacation-UH11
    [Documentation]   Creating Vacation without login

    ${start_time}=  add_timezone_time  ${tz}   0  10
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    #${DAY2}=  db.add_timezone_date  ${tz}  2        
    #Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    #${p3_id}=   Random Int  min=1000   max=9999
     ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}



JD-TC-CreateVacation-UH12
    [Documentation]    Add consumer to waitlist, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=4500   max=4999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    ${number}=  Random Int  min=4500  max=4999
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
   
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    ${sTime13}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime13}
    ${eTime13}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime13}
    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime13}  ${eTime13}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    ${resp}=  Appointment Status   ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid6}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pc_id6}  ${resp.json()[0]['id']}
 
    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}


   
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
     ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${sTime13}  ${eTime13}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime13}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime13}
       
    sleep  05s

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}

    

JD-TC-CreateVacation-UH13
    [Documentation]    Create vacation, then try to Add consumer to waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH14
    [Documentation]    Add consumer to Future day waitlist, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}


    ${desc}=   FakerLibrary.word
    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${FUTURE_Day}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}


    ${start_time}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}
    
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
     ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${FUTURE_Day}  ${FUTURE_Day}  ${EMPTY}  ${start_time}  ${end_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id}    description=${desc}      
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${FUTURE_Day}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${FUTURE_Day}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}



JD-TC-CreateVacation-UH15
    [Documentation]    Create vacation, then try to Add consumer to Future Day waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${FUTURE_Day}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}



JD-TC-CreateVacation-UH16
    [Documentation]    Consumer completes prepayment, then provider create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p_id}=  get_acc_id  ${PUSERNAME_E1}
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    # ${number}=  Random Int  min=1000  max=2000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+542087
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=300  max=500
    ${min_pre1}=  FakerLibrary.Random Int  min=200  max=299
    ${totalamt}=  Convert To Number  ${amt}  1
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${pre_float2}=  twodigitfloat  ${min_pre1}
    ${pre_float1}=  Convert To Number  ${min_pre1}  1

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consid1}  ${resp.json()['id']}
    
    ${msg}=  FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}  7  
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${u_id}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid18}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid18}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${p_id}  ${min_pre1}  ${purpose[0]}  ${cwid18}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid18}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid18}  ${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid18}  netTotal=${totalamt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1}  amountDue=${balamount}

    ${resp}=  Get consumer Waitlist By Id  ${cwid18}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${sTime1}=  db.subtract_timezone_time  ${tz}   0  15
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id18}    ${resp.json()['holidayId']}
    
    ${resp}=  Get Vacation By Id  ${v_id18}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id18}    description=${desc} 
    
    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id18}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id18}    description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
    ${resp}=  Activate Vacation    ${boolean[1]}    ${v_id18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   04s

    ${resp}=  Get Waitlist By Id  ${cwid18} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}     ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid18}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[3]}   waitlistStatus=${wl_status[4]}



JD-TC-CreateVacation-UH17
    [Documentation]    overlapped start time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${number}=  Random Int  min=3000  max=3999
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id05}   ${resp.json()[0]['id']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}


    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id3}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id3}  ${resp.json()}
  
   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v4_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${p1_id05}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v4_id}   description=${desc}
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

   
    ${1_Day}=  db.add_timezone_date  ${tz}   2
    ${Last_Day1}=  db.add_timezone_date  ${tz}   4
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${1_Day}  ${Last_Day1}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"
     
    ${resp} =   Delete Vacation    ${v4_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v4_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_NOT_FOUND}


   
JD-TC-CreateVacation-UH18
    [Documentation]    overlapped end time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  1      
    ${Last_Day}=  db.add_timezone_date  ${tz}  3     

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  

    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${DAY1}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v5_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${p1_id05}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v5_id}   description=${desc}
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${Last_Day1}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${p1_id05}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day1}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${HOLIDAY_ENDDATE_OVERLAPPED}
     

   












*** Comments ***

#####   cases related to a checking which is removed from rest side.

JD-TC-CreateVacation-UH2
    [Documentation]  Creating a Vacation, when Waitlist and Appointment is Disable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${dep_name4}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name4}
    ${dep_code4}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code4}
    ${dep_desc4}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc4}
    ${resp}=  Create Department  ${dep_name4}  ${dep_code4}  ${dep_desc4}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id04}  ${resp.json()}
    ${number}=  Random Int  min=8000  max=9999
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U5}
    Set Suite Variable  ${PUSERNAME_U5}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id04}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${countryCodes[0]}  ${PUSERNAME_U5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id5}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id02}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id02}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE7}=  FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE7}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id04}  ${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id7}  ${resp.json()}

    ${SERVICE8}=   FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE8}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id04}  ${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id8}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id5}  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}    appointment=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  1  15  
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
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User   ${u_id5}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Appointment Status   ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[0]}    waitlist=${bool[0]}

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${p1_id02}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${SHEDULE_NOT_FOUND}


JD-TC-CreateVacation-UH3
    [Documentation]  Creating a Vacation, on a non working day
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id05}  ${resp.json()} 
    ${number}=  Random Int  min=10000  max=12999
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id05}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id03}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id03}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List    1  2  3  4  5  6
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}
    #${lid}=  Create Sample Location
    #Set Suite Variable  ${lid}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${SERVICE8}=  FakerLibrary.name
    ${resp}=  Create Service For User  ${SERVICE8}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id05}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  1  15  
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
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User   ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}    waitlist=${bool[1]}

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}
    #${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    #Set Suite Variable    ${CUR_DAY}
    ${curr_weekday}=  get_timezone_weekday  ${tz}
    ${daygap}=  Evaluate  7-${curr_weekday}
    ${DAYUH3}=  db.add_timezone_date  ${tz}  ${daygap}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${p1_id03}  ${recurringtype[1]}  ${list}  ${DAYUH3}  ${DAYUH3}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${SHEDULE_NOT_FOUND}  

JD-TC-CreateVacation-UH7
    [Documentation]   Giving Date is Empty when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    #${DAY2}=  db.add_timezone_date  ${tz}  2        
    #Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    #${p3_id}=   Random Int  min=1000   max=9999
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${empty}  ${desc}  ${u_id}
    Log  ${resp.json()}
     ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"

JD-TC-CreateVacation-UH17
    [Documentation]   Giving time is Empty when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    #${DAY2}=  db.add_timezone_date  ${tz}  2        
    #Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    #${p3_id}=   Random Int  min=1000   max=9999
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${empty}  ${desc}  ${u_id}
    Log  ${resp.json()}
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${NULL}  ${NULL}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"

JD-TC-CreateVacation-22
    [Documentation]  Get appointment schedule by provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()}

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+345
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id3}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${dep_id3}  ${countryCodes[0]}  ${dep_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  address=${address}  mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.${test_mail}  city=${location}  state=${state}  deptId=${dep_id3}  subdomain=${userSubDomain}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}


        # ${start_time}=   db.get_time_by_timezone  ${tz}  
    ${start_time}=   db.get_time_by_timezone  ${tz}   
    Set Suite Variable   ${start_time}
  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    # ${resp}=  Create Vacation  ${start_time}  ${end_time}  ${CUR_DAY}  ${desc}  ${u_id}
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  0  ${start_time}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${v2_id}  ${resp.json()}
    Set Suite Variable  ${v2_id}    ${resp.json()['holidayId']}
    
