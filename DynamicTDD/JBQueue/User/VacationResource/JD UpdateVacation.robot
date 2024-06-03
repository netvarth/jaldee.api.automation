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
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
@{emptylist} 

***Test Cases***

JD-TC-UpdateVacation-1
    [Documentation]   Update Vacation after Created a Vacation when Waitlist is Enable
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${PUSERNAME_E3}=  Evaluate  ${PUSERNAME}+98704078
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E3}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E3}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E3}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E3}${\n}
    Set Suite Variable  ${PUSERNAME_E3}
    ${id}=  get_id  ${PUSERNAME_E3}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERNAME_E3}+1099844421
    ${ph2}=  Evaluate  ${PUSERNAME_E3}+2099844432
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
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Test Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  4  30  
    Set Test Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
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
        ${resp1}=  Enable Waitlist
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Toggle Department Enable
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

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
    

    # ${resp}=  View Waitlist Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Toggle Department Enable
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END
    
    # sleep  2s

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode

    ${number}=  Random Int  min=20000  max=21999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${user_id}  ${resp.json()}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p1_id_0AB}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${user_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}    appointment=${bool[1]}

    ${start_time}=  add_timezone_time  ${tz}  0  20  
    ${end_time}=    add_timezone_time  ${tz}   1  40 
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${user_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id_A}    ${resp.json()['holidayId']}
    
    
    ${start_time2}=  add_timezone_time  ${tz}  1  50  
    ${end_time2}=    add_timezone_time  ${tz}  2  15   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc2}  ${user_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time2}  ${end_time2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}   description=${desc2}     
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time2}
         
   
JD-TC-UpdateVacation-2
    [Documentation]   Again Update Vacation when Waitlist is Enabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time3}=  add_timezone_time  ${tz}  0  20  
    ${end_time3}=    add_timezone_time  ${tz}   1  40 
    
    ${desc3}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc3}  ${user_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time3}  ${end_time3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}   description=${desc3} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time3}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time3}
         

JD-TC-UpdateVacation-3
    [Documentation]   Waitlist is Enabled and given the future date to Update Vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE4}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  00
    ${queue_name1}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${user_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    #${resp}=  Waitlist Status    ${toggle[0]}
    #Log  ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}

    ${start_time}=  add_timezone_time  ${tz}  0  30  
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    ${DAY2}=  db.add_timezone_date  ${tz}  2        
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${user_id}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id1}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${user_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id1}   description=${desc}     
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
         
    ${desc4}=    FakerLibrary.name
    ${F_Day}=  db.add_timezone_date  ${tz}   3
    ${F_Day1}=  db.add_timezone_date  ${tz}   6
    ${resp}=  Update Vacation   ${v_id1}  ${desc4}  ${user_id}  ${recurringtype[1]}  ${list}  ${F_Day}  ${F_Day1}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id1}   description=${desc4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${F_Day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${F_Day1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
         

JD-TC-UpdateVacation-4
    [Documentation]   Update Vacation after Created a Vacation when Appointment is Enable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id01}  ${resp.json()} 

    ${number}=  Random Int  min=82000  max=93999
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id01}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}


    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${eTime1}=  add_timezone_time  ${tz}  4  00  

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
    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
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
         

JD-TC-UpdateVacation-5
    [Documentation]   Again Update Vacation when Appointment is Enable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
         

JD-TC-UpdateVacation-6
    [Documentation]   Waitlist is Enable and given the future date to create and update vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
   
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id7}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${delta}=  FakerLibrary.Random Int  min=90  max=120
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id7}  ${resp.json()}
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


    ${start_time}=  add_timezone_time  ${tz}   1  20
    ${end_time}=    add_timezone_time  ${tz}   1  40 
    ${Future_DAY}=  db.add_timezone_date  ${tz}  3  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${Future_DAY}  ${Future_DAY}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id_B7}    ${resp.json()['holidayId']}
    

    ${start_time2}=  add_timezone_time  ${tz}  1  30  
    ${end_time2}=    add_timezone_time  ${tz}  2  00   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B7}  ${desc2}  ${u_id}  ${recurringtype[1]}  ${list}  ${Future_DAY}  ${Future_DAY}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_B7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_B7}   description=${desc2} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${Future_DAY}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${Future_DAY}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time2}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time2}
         

JD-TC-UpdateVacation-7
    [Documentation]   Waitlist is Enable and given the future date to create and update vacation (Set StartTime as todays Past Time)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
    ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id}
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
         


JD-TC-UpdateVacation-8
    [Documentation]   Update Vacation with multiple users with Future Date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()} 
    
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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u2_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p9_id2}   ${resp.json()[1]['id']}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u2_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u2_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    

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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${P1_id01}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id01}   ${resp.json()[1]['id']}

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

    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}    waitlist=${bool[1]}

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time}  ${end_time}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id04}    ${resp.json()['holidayId']}
    

    ${start_time2}=  add_timezone_time  ${tz}   2  05
    ${end_time2}=    add_timezone_time  ${tz}   3  05 
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id04}  ${desc2}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id04}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id04}   description=${desc2} 
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
         
JD-TC-UpdateVacation-9
    [Documentation]   update with different user and Different Branch with out of Time Frame
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
         


JD-TC-UpdateVacation-10
    [Documentation]   update with different Branch and different user with outof Time Frame
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${start_time4}=  add_timezone_time  ${tz}  1  30  
    ${end_time4}=    add_timezone_time  ${tz}   4  10 
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc4}  ${user_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time4}  ${end_time4}  
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
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${start_time7}=  add_timezone_time  ${tz}  2  15  
#     Set Suite Variable   ${start_time7}
#     ${end_time7}=    add_timezone_time  ${tz}  3  15   
#     Set Suite Variable    ${end_time7}
#     ${desc7}=    FakerLibrary.name
#     Set Test Variable      ${desc7}
#     ${CUR_Day7}=  db.add_timezone_date  ${tz}  1  
#     # ${resp}=  Update Vacation  ${v_id04}  ${start_time7}  ${end_time7}  ${CUR_Day7}  ${desc7}  ${u2_id}
#     ${resp}=  Update Vacation   ${v_id04}  ${desc7}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day7}  ${CUR_Day7}  ${EMPTY}  ${start_time7}  ${end_time7}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANT_CHANGE_DATE}"


JD-TC-UpdateVacation-UH1
    [Documentation]  Provider ID is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time5}=  add_timezone_time  ${tz}   2  18
    ${end_time5}=    add_timezone_time  ${tz}  2  50   
    ${desc5}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id04}  ${desc5}  ${NULL}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time5}  ${end_time5}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found 


JD-TC-UpdateVacation-UH2
    [Documentation]   Vacation ID is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
    ${resp}=  Encrypted Provider Login  ${PUSERNAME76}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time8}=  add_timezone_time  ${tz}   2  13
    ${end_time8}=    add_timezone_time  ${tz}   3  13 
    ${desc8}=    FakerLibrary.name
    ${CUR_Day8}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Update Vacation   ${v_id04}  ${desc8}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day8}  ${CUR_Day8}  ${EMPTY}  ${start_time8}  ${end_time8}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found

    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-UpdateVacation-UH4
    [Documentation]  Update Vacation Using Consumer Number
    ${resp}=   Consumer Login  ${CUSERNAME6}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${start_time9}=  add_timezone_time  ${tz}   2  12
    ${end_time9}=    add_timezone_time  ${tz}   3  12 
    ${desc9}=    FakerLibrary.name
    ${CUR_Day9}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Update Vacation   ${v_id04}  ${desc9}  ${u2_id}  ${recurringtype[1]}  ${list}  ${CUR_Day9}  ${CUR_Day9}  ${EMPTY}  ${start_time9}  ${end_time9}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
 


JD-TC-UpdateVacation-UH5
    [Documentation]  changing the User ID in the Update Vacation, another user_id of that same provider is used
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Vacation By Id  ${v_id04}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id04}  
    

    ${start_time7}=  add_timezone_time  ${tz}  1  05  
    ${end_time7}=    add_timezone_time  ${tz}   2  05 
    ${desc7}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id04}  ${desc7}  ${u_id01}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time7}  ${end_time7}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}

    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANNOT_UPDATE_TIME}"


JD-TC-UpdateVacation-UH6
    [Documentation]   Update Vacation with same vacation_id and user_id, But Different Branch login
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    ${start_time2}=  add_timezone_time  ${tz}  1  30  
    ${end_time2}=    add_timezone_time  ${tz}  2  00   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_A}  ${desc2}  ${user_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found

    # Should Be Equal As Strings  ${resp.status_code}   401
    # Should Be Equal As Strings    ${resp.json()}    "${NO_PERMISSION}"



JD-TC-UpdateVacation-UH7
    [Documentation]   Update Vacation with Different Branch and Different user 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${start_time2}=  add_timezone_time  ${tz}  1  50  
    ${end_time2}=    add_timezone_time  ${tz}  2  15   
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id_B}  ${desc2}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_day}  ${CUR_day}  ${EMPTY}  ${start_time2}  ${end_time2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found 

    # Should Be Equal As Strings  ${resp.status_code}   401
    # Should Be Equal As Strings    ${resp.json()}    "${NO_PERMISSION}"

JD-TC-UpdateVacation-UH8
    [Documentation]  Update vacation using a past time for a valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
    # ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U1}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${P1_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
     
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  45
    ${eTime1}=  add_timezone_time  ${tz}  2  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
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
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[1]}

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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+547397
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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
      

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  00
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  8  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
    # ${resp}=  Appointment Status   ${toggle[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${resp}=  Waitlist Status    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}

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
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}


    ${start_time}=  add_timezone_time  ${tz}  0  15  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
  
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['waitlistCount']}   1
    Should Be Equal As Strings   ${resp.json()['apptCount']}       0


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
       
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}

    ${start_time4}=  add_timezone_time  ${tz}  0  30  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time4}  ${end_time4}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}



JD-TC-UpdateVacation-UH10
    [Documentation]    Update vacation, then try to Add consumer to waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${start_time4}=  add_timezone_time  ${tz}  0  15  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time4}  ${end_time4}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}


JD-TC-UpdateVacation-UH11
    [Documentation]    Add consumer to Future day waitlist, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}


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
       
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}
    ${resp}=  Activate Vacation    ${boolean[1]}   ${v_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   04s

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${FUTURE_Day}  waitlistStatus=${wl_status[4]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${pcid6}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${pcid6}



JD-TC-UpdateVacation-UH12
    [Documentation]    Create vacation, then try to Add consumer to Future Day waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  
    ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${FUTURE_Day}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}



JD-TC-UpdateVacation-UH13
    [Documentation]    Consumer completes prepayment, then provider create and update vacation, and again change checkin status of consumer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p_id}=  get_acc_id  ${PUSERNAME_E3}
    clear_customer   ${PUSERNAME_E3}

    # ${resp}=  Toggle Department Enable
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200

    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=500   max=999
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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${min_pre1}=  FakerLibrary.Random Int  min=200  max=${amt}
    ${totalamt}=  Convert To Number  ${amt}  1
    ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${pre_float2}=  twodigitfloat  ${min_pre1}
    ${pre_float1}=  Convert To Number  ${min_pre1}  1
    ${SERVICE1}=  FakerLibrary.WORD

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre1}  ${totalamt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

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

    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id}  ${msg}  ${bool[0]}  ${u_id}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid11}  ${wid[0]} 


    # ${resp}=  AddCustomer  ${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${pcid1}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    # ${resp}=  ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Conid1}  ${resp.json()['id']}
    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id}  ${msg}  ${bool[0]}  ${u_id}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${p_id}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${Conid1}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${start_time}=  add_timezone_time  ${tz}  0  15  
    ${end_time}=    add_timezone_time  ${tz}  1  30  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Vacation   ${u_id}
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
    ${resp}=  Activate Vacation    ${boolean[1]}   ${v_id}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time4}=  add_timezone_time  ${tz}  0  30  
    ${end_time4}=    add_timezone_time  ${tz}  2  00  
    ${desc4}=    FakerLibrary.name
    ${DAY}=  db.add_timezone_date  ${tz}  3  
    ${resp}=  Update Vacation   ${v_id}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${start_time4}  ${end_time4}   
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

JD-TC-UpdateVacation-UH14
    [Documentation]   create vacation and then creating another vacation and update vacation between this day(start date is already a holiday)

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p_id5}   ${resp.json()[0]['id']}
    
      
  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id5}  ${u_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id5}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  00
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id5}  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id5}  ${resp.json()}
    

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


JD-TC-UpdateVacation-UH15
    [Documentation]     create vacation and then update that vacation with overlapping the last date(last date is already a holiday)

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p_id6}   ${resp.json()[0]['id']}

    # ${resp}=  Appointment Status   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id6}  ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id6}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime6}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable  ${sTime6}
    ${eTime6}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable  ${eTime6}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime6}  ${eTime6}  1  5  ${lid}  ${u_id6}  ${s_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id6}  ${resp.json()}
    
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



JD-TC-UpdateVacation-12
    [Documentation]   create 3  vacation and then updating the holiday here extending the last date

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
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



#waiting time cases

JD-TC-UpdateVacation-13
    [Documentation]  Take account level and user level chekins and update both vactions time then check service time and waiting time

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${PUSERNAME_E2}=  Evaluate  ${PUSERNAME}+788105177
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E2}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E2}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E2}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E2}${\n}
    Set Suite Variable  ${PUSERNAME_E2}
    ${id}=  get_id  ${PUSERNAME_E2}
    ${bs}=  FakerLibrary.bs

    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    ${ph1}=  Evaluate  ${PUSERNAME_E2}+1000810001
    ${ph2}=  Evaluate  ${PUSERNAME_E2}+2000810001
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
    Set Suite Variable  ${DAY1}  
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
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=11  max=20
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${sId_2}  ${resp.json()} 

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
   
    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${sId_2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=1

    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    # ${strt_time1}=   db.get_time_by_timezone   ${tz}  
    ${strt_time1}=   db.get_time_by_timezone  ${tz} 
    ${end_time1}=    add_timezone_time  ${tz}  1  00  
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY1}  ${Last_Day}  ${EMPTY}  ${strt_time1}  ${end_time1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}

    ${resp}=  Activate Holiday  ${boolean[0]}   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${wait_time}=  Evaluate  ((${duration}+${s_dur2})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}

    ${serviceTime0}=   add_two   ${end_time1}      ${wait_time}


    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 

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
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
     

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${sTime1}=  add_timezone_time  ${tz}  2  00   
    ${eTime1}=  add_timezone_time  ${tz}  5  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid2}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid3}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=1

    # ${resp}=  Get Waitlist Today  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}  
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 


    ${eTime11}=  add_timezone_time  ${tz}  3  00  
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY1}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime11}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v4_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v4_id}   description=${desc}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${DAY1}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime11}

    ${resp}=  Activate Vacation   ${boolean[1]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${serviceTime1}=   add_two   ${eTime11}         ${dur}
   
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime0} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${eTime11}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
   
    # ${resp}=  Get Waitlist Today  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${eTime11}
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time} 
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime0}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    # Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
   

    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v4_id}  ${desc2}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Activate Vacation   ${boolean[1]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${serviceTime1}=   add_two   ${eTime1}         ${dur}
   
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime0} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${eTime1}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
   
    # ${resp}=  Get Waitlist Today  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime0}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    # Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
   
JD-TC-UpdateVacation-14
    [Documentation]  Take user level chekins and update vactions time and cancel one waitlist then check service time and waiting time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${ph2}=  Evaluate  ${PUSERNAME}+845112
    clear_users  ${ph2}
    Set Suite Variable  ${ph2}

    clear_customer   ${PUSERNAME_E2}
    clear_customer   ${ph2}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${ph2}  ${countryCodes[0]}  ${ph2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()} 

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${description2}=  FakerLibrary.sentence
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description2}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  4  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id2}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id2}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid1}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id2}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=1

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid2}  ${s_id1}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id2}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=2

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz} 
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${u_id2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v4_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v4_id}   description=${desc}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

    ${resp}=  Activate Vacation   ${boolean[1]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${wait_time}=  Evaluate  ((${dur}+${dur1})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${serviceTime1}=   add_two   ${eTime1}         ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz} 
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v4_id}  ${desc2}  ${u_id2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Activate Vacation   ${boolean[1]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${serviceTime1}=   add_two   ${eTime1}         ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}
  
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[4]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
   

JD-TC-UpdateVacation-15
    [Documentation]  Take user level chekins and update vactions time and cancel one waitlist then revert it to checkin state then check service time and waiting time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${ph3}=  Evaluate  ${PUSERNAME}+846113
    clear_users  ${ph3}
    Set Suite Variable  ${ph3}

    clear_customer   ${PUSERNAME_E2}
    clear_customer   ${ph3}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${ph3}  ${countryCodes[0]}  ${ph3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}
   
     

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

    ${description2}=  FakerLibrary.sentence
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description2}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  4  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id3}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id3}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid1}  ${s_id}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id3}  ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=1

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid2}  ${s_id1}  ${que_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id3}  ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=2


    ${wait_time}=  Evaluate  ((${dur}+${dur1})/2)/1
    ${wait_time}=  Convert To Integer  ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}  
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v4_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v4_id}   description=${desc}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${Last_Day}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${eTime1}

    ${resp}=  Activate Vacation   ${boolean[0]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${serviceTime1}=   add_two   ${eTime1}       ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${desc2}=    FakerLibrary.name
    ${resp}=  Update Vacation   ${v4_id}  ${desc2}  ${u_id3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Activate Vacation   ${boolean[0]}   ${v4_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   03s

    ${serviceTime1}=   add_two   ${eTime1}         ${wait_time}
    ${serviceTime2}=   add_two   ${serviceTime1}   ${wait_time}

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}

    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]} 

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[4]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}


    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${eTime1}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time} 
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime1} 
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[0]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time1}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime2}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}


JD-TC-UpdateVacation-16
    [Documentation]  Activate Vacation to user in account level and check both acoount and user level checkins
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${account_id}  ${resp2.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_queue      ${HLPUSERNAME2}
    clear_service    ${HLPUSERNAME2}
    clear_customer   ${HLPUSERNAME2}
    reset_user_metric   ${account_id}

    ${pid}=  get_acc_id  ${HLPUSERNAME2}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']} 

    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=2   max=4
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${sId_2}  ${resp.json()} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  5  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=10   max=15 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}  ${sId_2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}\

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
        
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME2}'
                clear_users  ${user_phone}
            END
        END
    END
     
    ${ph1}=  Evaluate  ${HLPUSERNAME2}+100044990
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

    ${whpnum}=  Evaluate  ${HLPUSERNAME2}+336245
    ${tlgnum}=  Evaluate  ${HLPUSERNAME2}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid3}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid4}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}
    ${resp}=  Activate Holiday  ${boolean[0]}   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wait_time0}=  Evaluate  ((${duration}+${s_dur2})/2)/1
    ${wait_time0}=  Convert To Integer  ${wait_time0}

    ${serviceTime0}=   add_two   ${end_time}     ${wait_time0}

    ${serviceTime1}=   add_two   ${end_time}     ${dur}
   
    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${end_time}
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   ${wait_time0}
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${serviceTime0}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    # Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}
   

JD-TC-UpdateVacation-17
    [Documentation]  Activate delete account level holiday
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    clear_queue      ${HLPUSERNAME1}
    clear_service    ${HLPUSERNAME1}
    clear_customer   ${HLPUSERNAME1}

    ${pid}=  get_acc_id  ${HLPUSERNAME1}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}   ${EMPTY}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']} 
 
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${s_dur2}=  Random Int  min=2  max=4
    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${s_dur2}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${sId_2}  ${resp.json()} 

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=1
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}  ${sId_2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
       
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME1}'
                clear_users  ${user_phone}
            END
        END
    END
    
   
    ${ph1}=  Evaluate  ${HLPUSERNAME1}+1000440000
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

    ${whpnum}=  Evaluate  ${HLPUSERNAME1}+336245
    ${tlgnum}=  Evaluate  ${HLPUSERNAME1}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  4  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid3}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid2[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid4}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid3[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${strt_time}=   db.get_time_by_timezone   ${tz}  
    ${strt_time}=   db.get_time_by_timezone  ${tz}      
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${strt_time}  ${end_time}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${holidayId}    ${resp.json()['holidayId']}

    ${resp}=  Activate Holiday  ${boolean[0]}   ${holidayId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${wait_time0}=  Evaluate  ((${duration}+${s_dur2})/2)/1
    ${wait_time0}=  Convert To Integer  ${wait_time0}

    ${serviceTime0}=   add_two   ${end_time}     ${wait_time0}

    ${serviceTime1}=   add_two   ${end_time}     ${dur}

    # ${resp}=  Get Waitlist Today  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}   0 
    # Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}       ${end_time}
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}   ${wait_time0} 
    # Should Be Equal As Strings  ${resp.json()[1]['serviceTime']}       ${serviceTime0} 
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}   0
    # Should Be Equal As Strings  ${resp.json()[2]['serviceTime']}       ${end_time}
    # Should Be Equal As Strings  ${resp.json()[2]['waitlistStatus']}    ${wl_status[1]}
    # Should Be Equal As Strings  ${resp.json()[3]['appxWaitingTime']}   ${dur} 
    # Should Be Equal As Strings  ${resp.json()[3]['serviceTime']}       ${serviceTime1}
    # Should Be Equal As Strings  ${resp.json()[3]['waitlistStatus']}    ${wl_status[1]}

    ${resp}=   Delete Holiday  ${holidayId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Holiday By Account
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain   ${resp.json()}  "id":"${holidayId}"

    ${resp}=  Get Waitlist Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateVacation-18
    [Documentation]  Assingn waitlist to user
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME74}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    clear_queue      ${PUSERNAME74}
    clear_service    ${PUSERNAME74}
    clear_customer   ${PUSERNAME74}

    ${pid}=  get_acc_id  ${PUSERNAME74}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


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
     
    ${ph1}=  Evaluate  ${PUSERNAME74}+1000440000
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

    ${whpnum}=  Evaluate  ${PUSERNAME74}+336245
    ${tlgnum}=  Evaluate  ${PUSERNAME74}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${u_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation   ${desc}  ${u_id1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v4_id}    ${resp.json()['holidayId']}
   
    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id1}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id1}





*** Comments ***
JD-TC-UpdateVacation-13
    [Documentation]    Take a appointment and then create vacation on after that appointment time

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid_B15}=  get_acc_id  ${PUSERNAME_E3}
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
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
        #     Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        # END
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








































*** Comments ***

JD-TC-UpdateVacation-UH2
    [Documentation]  Given date is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time2}=  add_timezone_time  ${tz}   2  10
    Set Suite Variable   ${start_time2}
    ${end_time2}=    add_timezone_time  ${tz}   3  10 
    Set Suite Variable    ${end_time2}
    ${desc2}=    FakerLibrary.name
    Set Test Variable      ${desc2}
    ${CUR_Day2}=  db.add_timezone_date  ${tz}  2  
    # ${resp}=  Update Vacation  ${v_id04}  ${start_time2}  ${end_time2}  ${empty}  ${desc2}  ${u2_id}
    ${resp}=  Update Vacation   ${v_id04}  ${desc2}  ${u2_id}  ${recurringtype[1]}  ${list}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${start_time2}  ${end_time2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"


JD-TC-UpdateVacation-UH8
    [Documentation]  StartTime is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time3}=  add_timezone_time  ${tz}   2  25
    Set Suite Variable   ${start_time3}
    ${end_time3}=    add_timezone_time  ${tz}  2  40   
    Set Suite Variable    ${end_time3}
    ${desc3}=    FakerLibrary.name
    Set Test Variable      ${desc3}
    #${CUR_Day3}=  db.add_timezone_date  ${tz}  3  
    
    ${resp}=  Update Vacation  ${v_id}  ${empty}  ${end_time3}  ${CUR_day}  ${desc3}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANT_CHANGE_DATE}"

JD-TC-UpdateVacation-UH9
    [Documentation]  EndTime is Empty in the Update Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time4}=  add_timezone_time  ${tz}   2  20
    Set Suite Variable   ${start_time4}
    ${end_time4}=    add_timezone_time  ${tz}  2  45   
    Set Suite Variable    ${end_time4}
    ${desc4}=    FakerLibrary.name
    Set Test Variable      ${desc4}
    #${CUR_Day4}=  db.add_timezone_date  ${tz}  4  
    
    ${resp}=  Update Vacation  ${v_id}  ${start_time4}  ${empty}  ${CUR_day}  ${desc4}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_CANT_CHANGE_DATE}"

JD-TC-UpdateVacation-4
    [Documentation]   Waitlist is Enabled and given the future date to Update Vacation (Set StartTime as todays Past Time)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7

    Set Suite Variable  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
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
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}

    # ${start_time}=  add_timezone_time  ${tz}  2  00  
    # Set StartTime as todays Past Time To create Vacation
    ${start_time}=  db.subtract_timezone_time  ${tz}  1  30
    Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    Set Suite Variable    ${end_time}
    ${DAY2}=  db.add_timezone_date  ${tz}  3        
    Set Suite Variable  ${DAY2}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id2}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   2  id=${v_id2}    description=${desc}      
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['startDate']}                         ${DAY2}
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['terminator']['endDate']}             ${DAY2}  
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[2]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}


    ${desc4}=    FakerLibrary.name
    ${F_Day}=  db.add_timezone_date  ${tz}   3
    ${F_Day1}=  db.add_timezone_date  ${tz}   6
    ${resp}=  Update Vacation   ${v_id2}  ${desc4}  ${u_id}  ${recurringtype[1]}  ${list}  ${F_Day}  ${F_Day1}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Vacation By Id  ${v_id_A}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id_A}   description=${desc4} 
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['startDate']}                         ${F_Day}
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['terminator']['endDate']}             ${F_Day1}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
          
