
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
Variables         /ebs/TDD/varfiles/musers.py
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


JD-TC-UpdateVacation-1
    [Documentation]   Update Vacation after Created a Vacation when appointment is Enable
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+98702045
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E1}${\n}
    Set Suite Variable  ${MUSERNAME_E1}
    ${id}=  get_id  ${MUSERNAME_E1}
    ${bs}=  FakerLibrary.bs
   
    
    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1099844421
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2099844432
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Test Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  4  30  
    Set Test Variable  ${BeTime30}  ${eTime}
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

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

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
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
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
  
    ${number}=  Random Int  min=22000  max=23999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}


    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}


    ${start_time}=  add_timezone_time  ${tz}   1  20
    ${end_time}=    add_timezone_time  ${tz}   1  40 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id_B}    ${resp.json()['holidayId']}
    

    ${start_time2}=  add_timezone_time  ${tz}  1  30  
    ${end_time2}=    add_timezone_time  ${tz}  2  00   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B}  ${desc2}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time2}  ${end_time2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_B}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_B}   description=${desc2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time2}
         

JD-TC-UpdateVacation-2
    [Documentation]   Again Update Vacation when Appointment is Enable
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_day}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_day}   
    ${start_time3}=  add_timezone_time  ${tz}  1  30  
    ${end_time3}=    add_timezone_time  ${tz}  2  00   
    ${desc3}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B}  ${desc3}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time3}  ${end_time3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_B}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_B}    description=${desc3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time3}
         

JD-TC-UpdateVacation-3
    [Documentation]   Waitlist is Enable and given the future date to create and update vacation (Set StartTime as todays Past Time)
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.subtract_timezone_time  ${tz}   1  00
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id8}  ${resp.json()}


    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id8}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Waitlist Status    ${toggle[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}


    ${start_time}=  db.subtract_timezone_time  ${tz}   0  20
    ${end_time}=    add_timezone_time  ${tz}   1  40 
    ${Future_DAY}=  db.add_timezone_date  ${tz}  4  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${Future_DAY}  ${Future_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id_B8}    ${resp.json()['holidayId']}
    

    ${start_time3}=  db.subtract_timezone_time  ${tz}   0  45
    ${end_time3}=    add_timezone_time  ${tz}  0  45  
    ${desc3}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B8}  ${desc3}  ${u_id}  ${recurringtype[1]}  ${list}  ${Future_DAY}  ${Future_DAY}  ${EMPTY}  ${start_time3}  ${end_time3}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_B8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_B8}   description=${desc3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${Future_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Future_DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time3}
         


JD-TC-UpdateVacation-4
    [Documentation]   Update Vacation with multiple users with Future Date
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
    # ${dep_name1}=  FakerLibrary.bs
    # ${dep_code1}=   Random Int  min=100   max=999
    # ${dep_desc1}=   FakerLibrary.word  
    # ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${dep_id1}  ${resp.json()} 
    
    ${number}=  Random Int  min=20000  max=21999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u2_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u2_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u2_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}
    
    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u2_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id8}  ${resp.json()}


    ${number}=  Random Int  min=30000  max=49999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id01}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=60  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}
   
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id01}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time}  ${end_time}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id_A}    ${resp.json()['holidayId']}
    

    ${start_time2}=  add_timezone_time  ${tz}   2  05
    ${end_time2}=    add_timezone_time  ${tz}   3  05 
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc2}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}   description=${desc2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time2}
         
    ${start_time3}=  add_timezone_time  ${tz}   1  20
    ${end_time3}=    add_timezone_time  ${tz}  1  50   
    ${CUR_day3}=  db.add_timezone_date  ${tz}  2        
    ${desc3}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc3}  ${u_id01}  ${recurringtype[1]}  ${list}  ${CUR_day3}  ${CUR_day3}  ${EMPTY}  ${start_time3}  ${end_time3}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id05}    ${resp.json()['holidayId']}
    

    ${start_time4}=  add_timezone_time  ${tz}  1  30  
    ${end_time4}=    add_timezone_time  ${tz}   1  55 
    ${desc4}=    FakerLibrary.name
    ${CUR_day3}=  db.add_timezone_date  ${tz}  2        
    ${resp}=  Update Vacation   ${v_id05}  ${desc4}  ${u_id01}  ${recurringtype[1]}  ${list}  ${CUR_day3}  ${CUR_day3}  ${EMPTY}  ${start_time4}  ${end_time4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id05}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id05}    description=${desc4}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_day3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_day3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time4}
         
JD-TC-UpdateVacation-5
    [Documentation]   update with different user and Different Branch with out of Time Frame
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    ${start_time3}=  add_timezone_time  ${tz}  1  30  
    ${end_time3}=    add_timezone_time  ${tz}   4  10 
    ${desc3}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B}  ${desc3}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time3}  ${end_time3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()}    "${HOLIDAY_CANNOT_UPDATE_TIME}"
    ${resp}=  Get Vacation By Id  ${v_id_B}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_B}    description=${desc3}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time3}
         


JD-TC-UpdateVacation-6
    [Documentation]   update with different Branch and different user with outof Time Frame
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${start_time4}=  add_timezone_time  ${tz}  1  30  
    ${end_time4}=    add_timezone_time  ${tz}   4  10 
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc4}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time4}  ${end_time4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings    ${resp.json()}    "${HOLIDAY_CANNOT_UPDATE_TIME}"
    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}    description=${desc4}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_day}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time4}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time4}
         


# JD-TC-UpdateVacation-UH1
#     [Documentation]  changing the Date in the Update Vacation
#     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${start_time7}=  add_timezone_time  ${tz}  2  15  
#     Set Suite Variable   ${start_time7}
#     ${end_time7}=    add_timezone_time  ${tz}  3  15   
#     Set Suite Variable    ${end_time7}
#     ${desc7}=    FakerLibrary.name
#     Set Test Variable      ${desc7}
#     ${CUR_Day7}=  db.add_timezone_date  ${tz}  1  
#     # ${resp}=  Update Vacation  ${v_id_A}  ${start_time7}  ${end_time7}  ${CUR_Day7}  ${desc7}  ${u2_id}
#     ${resp}=  Update Vacation   ${v_id_A}  ${desc7}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day7}  ${CUR_Day7}  ${EMPTY}  ${start_time7}  ${end_time7}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANT_CHANGE_DATE}"


JD-TC-UpdateVacation-UH1
    [Documentation]  Provider ID is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time5}=  add_timezone_time  ${tz}   2  18
    ${end_time5}=    add_timezone_time  ${tz}  2  50   
    ${desc5}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc5}  ${NULL}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time5}  ${end_time5}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${PROVIDER_NOT_FOUND}

JD-TC-UpdateVacation-UH2
    [Documentation]   Vacation ID is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time6}=  add_timezone_time  ${tz}  2  15  
    ${end_time6}=    add_timezone_time  ${tz}   2  55 
    ${desc6}=    FakerLibrary.name
    ${CUR_Day6}=  db.add_timezone_date  ${tz}  6  
    ${resp}=  Update Vacation   ${EMPTY}  ${desc6}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day6}  ${CUR_Day6}  ${EMPTY}  ${start_time6}  ${end_time6}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_NOT_FOUND}


JD-TC-UpdateVacation-UH3
    [Documentation]  Trying Update Vacation Using Existing Branch Number
    ${resp}=  Encrypted Provider Login  ${MUSERNAME76}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time8}=  add_timezone_time  ${tz}   2  13
    ${end_time8}=    add_timezone_time  ${tz}   3  13 
    ${desc8}=    FakerLibrary.name
    ${CUR_Day8}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Update Vacation   ${v_id_A}  ${desc8}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day8}  ${CUR_Day8}  ${EMPTY}  ${start_time8}  ${end_time8}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${PROVIDER_NOT_FOUND}


JD-TC-UpdateVacation-UH4
    [Documentation]  Update Vacation Using Consumer Number
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${start_time9}=  add_timezone_time  ${tz}   2  12
    ${end_time9}=    add_timezone_time  ${tz}   3  12 
    ${desc9}=    FakerLibrary.name
    ${CUR_Day9}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Update Vacation   ${v_id_A}  ${desc9}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day9}  ${CUR_Day9}  ${EMPTY}  ${start_time9}  ${end_time9}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
 


JD-TC-UpdateVacation-UH5

    [Documentation]  changing the User ID in the Update Vacation, another user_id of that same provider is used
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}  
    

    ${start_time7}=  add_timezone_time  ${tz}  1  05  
    ${end_time7}=    add_timezone_time  ${tz}   2  05 
    ${desc7}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc7}  ${u_id01}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time7}  ${end_time7}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}

    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_UPDATE_TIME}"


JD-TC-UpdateVacation-UH6
    [Documentation]   Update Vacation with same vacation_id and user_id, But Different Branch login
    ${resp}=  Encrypted Provider Login  ${MUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    ${start_time2}=  add_timezone_time  ${tz}  1  30  
    ${end_time2}=    add_timezone_time  ${tz}  2  00   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc2}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${PROVIDER_NOT_FOUND}


JD-TC-UpdateVacation-UH7
    [Documentation]   Update Vacation with Different Branch and Different user 
    ${resp}=  Encrypted Provider Login  ${MUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${start_time2}=  add_timezone_time  ${tz}  1  50  
    ${end_time2}=    add_timezone_time  ${tz}  2  15   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B}  ${desc2}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${PROVIDER_NOT_FOUND}
   
JD-TC-UpdateVacation-UH8
    [Documentation]  Update vacation using a past time for a valid provider

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=4500   max=4999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Set Suite Variable  ${dep_id}  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${number}=  Random Int  min=2000  max=2999
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
  
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  45
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}
    # ${resp}=  Waitlist Status    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Accountsettings  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response   ${resp}    waitlist=${bool[1]}  appointment=${bool[1]}

    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  30
    ${eTime1}=  add_timezone_time  ${tz}  4  00   

    ${schedule_name}=  FakerLibrary.bs
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
    Verify Response   ${resp}    appointment=${bool[1]}   

    ${start_time}=  add_timezone_time  ${tz}   2  10 
    ${end_time}=    add_timezone_time  ${tz}   3  10 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id12}    ${resp.json()['holidayId']}
    

    ${start_time4}=  db.subtract_timezone_time  ${tz}  0  5
    ${end_time4}=    add_timezone_time  ${tz}   1  10
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id12}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time4}  ${end_time4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${HOLIDAY_START_TIME_INCORRECT}

  

JD-TC-UpdateVacation-UH9
    [Documentation]    Add consumer to waitlist, After that create and update vacation
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+547367
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  00  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name} 
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id8}  ${resp.json()}

    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}      appointment=${bool[1]}

    # ${resp}=  AddCustomer  ${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pcid6}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pc_id6}  ${resp.json()[0]['id']}
 
    # ${desc}=   FakerLibrary.word
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}
    # ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid}  ${wid[0]}
    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id8}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id8}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id}  ${cid}  ${s_id}  ${sch_id8}  ${DAY1}  ${cnote}  ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
   

    ${start_time}=  add_timezone_time  ${tz}  0  15  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
  
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   0
    Should Be Equal As Strings   ${resp.json()['apptCount']}       1


    ${resp}=   Get Vacation   ${u_id}
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
       
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   apptStatus=${apptStatus[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}                ${cid}
   
    ${start_time4}=  add_timezone_time  ${tz}  0  30  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time4}  ${end_time4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    apptStatus=${apptStatus[1]}  


JD-TC-UpdateVacation-UH10
    [Documentation]    Update vacation, then try to Add consumer to waitlist
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${start_time4}=  add_timezone_time  ${tz}  0  15  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time4}  ${end_time4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id8}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id8}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id}  ${cid}  ${s_id}  ${sch_id8}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  424
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}
     
          
    
    # ${desc}=   FakerLibrary.word
    # ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   422
    # Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}


JD-TC-UpdateVacation-UH11
    [Documentation]    Add consumer to Future day waitlist, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}      appointment=${bool[1]}

    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id8}  ${FUTURE_Day}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id8}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME19}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id}  ${cid}  ${s_id}  ${sch_id8}  ${FUTURE_Day}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${desc}=   FakerLibrary.word
    # ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    # ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${FUTURE_Day}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Test Variable  ${wid}  ${wid[0]}
    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   apptStatus=${apptStatus[1]}    
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
   

    ${start_time}=  add_timezone_time  ${tz}  0  15  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${FUTURE_Day}  ${FUTURE_Day}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v_id}    ${resp.json()['holidayId']}
   
    ${resp}=   Get Vacation    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id}    description=${desc}       
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${FUTURE_Day}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${FUTURE_Day}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Activate Vacation   ${boolean[1]}   ${v_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   04s

    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[4]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    # Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-UpdateVacation-UH12
    [Documentation]    Create vacation, then try to Add consumer to Future Day waitlist
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    # ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${FUTURE_Day}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   422
    # Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id8}  ${FUTURE_Day}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id8}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id}  ${cid}  ${s_id}  ${sch_id8}  ${FUTURE_Day}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  424
    Should Be Equal As Strings   ${resp.json()}    ${APPOINTMET_SLOT_NOT_AVAILABLE}


JD-TC-UpdateVacation-UH13
    [Documentation]   create vacation and then creating another vacation and update vacation between this day(start date is already a holiday)

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id5}  ${resp.json()} 
    
    ${number}=  Random Int  min=20000  max=21999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id5}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id5}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id5}  ${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}
    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id5}  ${s_id5}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id5}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id5}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${sDAY}=  db.add_timezone_date  ${tz}  1  
    ${eDAY}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${sDAY}  ${eDAY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id5}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id5}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id5}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${sDAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${eDAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
       

    ${sDAY1}=  db.add_timezone_date  ${tz}  4  
    ${eDAY1}=  db.add_timezone_date  ${tz}  6  
 
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${sDAY1}  ${eDAY1}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id5}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id6}  ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id6}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${sDAY1}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${eDAY1}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
       
    ${eDAY2}=  db.add_timezone_date  ${tz}  8  
    ${resp}=  Update Vacation   ${v_id6}  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${eDAY}  ${eDAY2}  ${EMPTY}  ${sTime1}  ${eTime1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_STARTDATE_OVERLAPPED}"
     
    ${resp} =   Delete Vacation    ${v_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NOT_FOUND}"

    ${resp} =   Delete Vacation    ${v_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_NOT_FOUND}


JD-TC-UpdateVacation-UH14
    [Documentation]     create vacation and then update that vacation with overlapping the last date(last date is already a holiday)

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
   

    ${sDAY}=  db.add_timezone_date  ${tz}  1  
    ${eDAY}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${sDAY}  ${eDAY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id5}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id5}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id5}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${sDAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${eDAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
       

    ${sDAY1}=  db.add_timezone_date  ${tz}  4  
    ${eDAY1}=  db.add_timezone_date  ${tz}  6  
 
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${sDAY1}  ${eDAY1}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id5}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id6}  ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id6}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${sDAY1}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${eDAY1}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}
       
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Update Vacation   ${v_id6}  ${desc}  ${u_id5}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${sDAY1}  ${EMPTY}  ${sTime1}  ${eTime1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_ENDDATE_OVERLAPPED}"
     
    ${resp} =   Delete Vacation    ${v_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NOT_FOUND}"

    ${resp} =   Delete Vacation    ${v_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}  ${HOLIDAY_NOT_FOUND}

JD-TC-UpdateVacation-11
    [Documentation]    create a future holiday and then update the holiday's start date to current day

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id6}  ${resp.json()} 
    
    ${number}=  Random Int  min=20000  max=21999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id6}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id6}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime6}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable  ${sTime6}
    ${eTime6}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable  ${eTime6}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id6}  ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id6}  ${resp.json()}
    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime6}  ${eTime6}  1  5  ${lid}  ${u_id6}  ${s_id6}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id6}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id6}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime6}  ${eTime6}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${sDAY}=  db.add_timezone_date  ${tz}  1  
    ${eDAY}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id6}  ${recurringtype[1]}  ${list}  ${sDAY}  ${eDAY}  ${EMPTY}  ${sTime6}  ${eTime6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id7}  ${resp.json()[0]['id']}
    Verify Response List   ${resp}   0  id=${v_id7}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${sDAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${eDAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime6}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime6}

 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Update Vacation   ${v_id7}  ${desc}  ${u_id6}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${eDAY}  ${EMPTY}  ${sTime6}  ${eTime6}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id7}  ${resp.json()[0]['id']}
    Verify Response List   ${resp}   0  id=${v_id7}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${eDAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime6}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime6}

    ${resp} =   Delete Vacation    ${v_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}  ${HOLIDAY_NOT_FOUND}



JD-TC-UpdateVacation-7
    [Documentation]   create 3  vacation and then updating the holiday here extending the last date

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sDAY}=  db.add_timezone_date  ${tz}  1  
    ${eDAY}=  db.add_timezone_date  ${tz}  3  

    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id6}  ${recurringtype[1]}  ${list}  ${sDAY}  ${eDAY}  ${EMPTY}  ${sTime6}  ${eTime6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id8}  ${resp.json()[0]['id']}
    Verify Response List   ${resp}   0  id=${v_id8}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${sDAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${eDAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime6}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime6}

 
    ${e_DAY}=  db.add_timezone_date  ${tz}  4  
    ${resp}=  Update Vacation   ${v_id8}  ${desc}  ${u_id6}  ${recurringtype[1]}  ${list}  ${sDAY}  ${e_DAY}  ${EMPTY}  ${sTime6}  ${eTime6}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id8}  ${resp.json()[0]['id']}
    Verify Response List   ${resp}   0  id=${v_id8}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${sDAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${e_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime6}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime6}

    ${resp} =   Delete Vacation    ${v_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Vacation By Id  ${v_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_NOT_FOUND}


*** Comments ***
JD-TC-UpdateVacation-UH13
    [Documentation]    Consumer completes prepayment, then provider create and update vacation, and again change checkin status of consumer
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    clear_customer   ${MUSERNAME_E1}
   
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME_E1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME_E1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    # ${resp}=  Toggle Department Enable
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+845019
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${min_pre1}=  FakerLibrary.Random Int  min=200  max=${amt}
    ${totalamt}=  Convert To Number  ${amt}  1
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${pre_float2}=  twodigitfloat  ${min_pre1}
    ${pre_float1}=  Convert To Number  ${min_pre1}  1

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid11}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid11}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${msg}=  FakerLibrary.word
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id}  ${msg}  ${bool[0]}  ${p1_id}   0
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${cwid11}  ${wid[0]} 

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    # ${msg}=  FakerLibrary.word
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id}  ${msg}  ${bool[0]}  ${p1_id}   0
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${wid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${cwid}  ${wid[0]} 

 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid}  ${p_id}  ${purpose[0]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}  netTotal=${totalamt}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1}  amountDue=${balamount}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${start_time}=  add_timezone_time  ${tz}  0  15  
    ${end_time}=    add_timezone_time  ${tz}  1  30  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${p1_id}
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
       
    ${resp}=  Activate Vacation   ${boolean[1]}   ${v_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   04s
    ${resp}=  Get Waitlist By Id  ${cwid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}   paymentStatus=${paymentStatus[3]}  partySize=1    waitlistedBy=${waitlistedby[0]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}     ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[3]}   waitlistStatus=${wl_status[4]}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time4}=  add_timezone_time  ${tz}  0  30  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${DAY}=  db.add_timezone_date  ${tz}  3  
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${p1_id}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${start_time4}  ${end_time4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Activate Vacation    ${boolean[1]}   ${v_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep  04s
    ${resp}=  Get Waitlist By Id  ${cwid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[1]}  partySize=1    waitlistedBy=${waitlistedby[0]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}      ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

JD-TC-UpdateVacation-13
    [Documentation]    Take a appointment and then create vacation on after that appointment time

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid_B15}=  get_acc_id  ${MUSERNAME_E1}
    Set Suite variable  ${pid_B15}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10         

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id6}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime6}  ${eTime6}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id6}  ${resp.json()}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id6}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id6}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment From User Side   ${cid}  ${s_id6}  ${sch_id6}  ${DAY1}  ${cnote}  ${u_id6}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}






    # ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${uname}  ${resp.json()['userName']}
    # ${JC_id01}=  get_id  ${CUSERNAME7} 
    
    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id6}   ${pid_B15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${p}=  Random Int  max=${num_slots-1}
    # Set Suite Variable   ${slot1}   ${slots[${p}]}

    # # ${q}=  Random Int  max=${num_slots-2}
    # # Set Test Variable   ${slot2}   ${slots[${q}]}
    # ${pcid1}=  get_id  ${CUSERNAME7}
    # ${appt_for1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}  
    # ${apptfor1}=   Create List  ${appt_for1}
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For User    ${pid_B15}  ${s_id6}  ${sch_id6}  ${DAY1}  ${cnote}  ${u_id6}   ${apptfor1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${apptid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${apptid1}  ${apptid[0]}
   
    # ${resp}=  Get Appointment By Id   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}












    # ${sTime6}=  add_timezone_time  ${tz}  0  15  
    # ${eTime6}=  add_timezone_time  ${tz}  4  00  

    ${sTime7}=  add_timezone_time  ${tz}  2  15  
    ${eTime7}=  add_timezone_time  ${tz}  4  00  


    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id6}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime7}  ${eTime7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id9}  ${resp.json()[0]['id']}
    Verify Response List   ${resp}   0  id=${v_id9}   description=${desc}       
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime7}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime7}

    ${resp}=  Activate Vacation    ${boolean[1]}   ${v_id9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   04s
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Delete Vacation1  ${v_id9} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200








