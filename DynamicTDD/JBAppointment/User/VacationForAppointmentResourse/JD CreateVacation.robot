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
    [Documentation]  Creating a Vacation when Appointment is Enabled
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${PUSERNAME_E1}=  Evaluate  ${PUSERNAME}+778806576
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    
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
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
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
  
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}   ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}

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
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v1_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation    ${p1_id}
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
    [Documentation]    Using Multiple Appointment solts when Appointment is Enable
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
    Set Suite Variable  ${u_id2}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id04}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id04}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
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
    # Set Suite Variable  ${schedule_name1}
    ${sTime1}=  add_timezone_time  ${tz}  0  20  
    # Set Suite Variable   ${start_time}
    ${eTime1}=    add_timezone_time  ${tz}  2  40   
    # Set Suite Variable    ${end_time}
    ${delta}=  FakerLibrary.Random Int  min=10  max=45
    # Set Suite Variable  ${delta}
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
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  30   
    # Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    # Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${p1_id04}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v4_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation     ${p1_id04}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v4_id}   description=${desc}
    
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Delete Vacation  ${v4_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
JD-TC-CreateVacation-3
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
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  30   
    # Set Suite Variable    ${end_time}    
    Set Suite Variable    ${DAY4}
    ${desc}=    FakerLibrary.name
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


JD-TC-CreateVacation-4
    [Documentation]    Multiple Appointment Solts and Appointment is Enable and given the future date to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name2}=  FakerLibrary.bs
    ${dep_code2}=   Random Int  min=100   max=999
    ${dep_desc2}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id01}  ${resp.json()}
    ${number}=  Random Int  min=3000  max=5999
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id01}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id09}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id09}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}   appointment=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=30  max=45
    # Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # Set Suite Variable   ${eTime1}
    
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id3}  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id01}  ${resp.json()}
  
    ${sTime1}=  add_timezone_time  ${tz}  1  10
    # Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=30  max=60
    # Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # Set Suite Variable   ${eTime1}
    
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User   ${u_id3}  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id02}  ${resp.json()}
    
    ${start_time}=  add_timezone_time  ${tz}  0  20  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  50   
    # Set Suite Variable    ${end_time}
    ${DAY5}=  db.add_timezone_date  ${tz}  5        
    Set Suite Variable  ${DAY5}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${DAY5}  ${DAY5}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v10_id}    ${resp.json()['holidayId']}


    ${resp}=   Get Vacation  ${u_id3}
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
       
    # ${resp}=  Delete Vacation  ${v_id} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateVacation-5
    [Documentation]  Creating a Vacation with out of timeframe schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  4  15  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}   4  35 
    # Set Suite Variable    ${end_time}
    ${DAY2}=  db.add_timezone_date  ${tz}  4  
    # Set Suite Variable    ${DAY2}
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY2}  ${EMPTY}  ${start_time}  ${end_time}   
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
       

JD-TC-CreateVacation-UH1
    [Documentation]  Create an already existing Vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${start_time}=  add_timezone_time  ${tz}  0  30  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  1  30   
    # Set Suite Variable    ${end_time}
    ${DAY6}=  db.add_timezone_date  ${tz}  4  
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${DAY6}  ${DAY6}  ${EMPTY}  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH2
    [Documentation]   Provider ID is Empty when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  2  00  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    # Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    
    ${resp}=  Create Vacation  ${desc}  ${NULL}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    Provider Not Found
    
JD-TC-CreateVacation-UH3
    [Documentation]   Giving Invalid Provider ID when Creating Vacation
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${start_time}=  add_timezone_time  ${tz}  1  00  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    # Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    ${p1_id10}=   Random Int   min=100000   max=999999

    ${resp}=  Create Vacation  ${desc}  ${p1_id10}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   Provider Not Found 


JD-TC-CreateVacation-UH4
    [Documentation]  create a past date  vacation for a valid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${start_time}=  add_timezone_time  ${tz}  1  00  
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    # Set Suite Variable    ${end_time}

    ${PAST_DAY}=  db.add_timezone_date  ${tz}  -1
    Set Suite Variable   ${PAST_DAY}
    
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${PAST_DAY}  ${PAST_DAY}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_START_DATE_INCORRECT}



JD-TC-CreateVacation-UH5
    [Documentation]  create  an overlapping end time for an existing vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}

    ${resp}=  Get Vacation By Id  ${v10_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_time}=  add_timezone_time  ${tz}   1  40
    ${end_time}=    add_timezone_time  ${tz}  2  30  
    ${DAY6}=  db.add_timezone_date  ${tz}  6  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${DAY5}  ${DAY5}  ${EMPTY}  ${start_time}  ${end_time}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH6
    [Documentation]  create  an overlapping start time for an existing vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}

    ${start_time}=  db.subtract_timezone_time  ${tz}  0  30
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    ${DAY6}=  db.add_timezone_date  ${tz}  6        
    ${desc}=    FakerLibrary.name
     ${resp}=  Create Vacation  ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${DAY5}  ${DAY5}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}

JD-TC-CreateVacation-UH7
    [Documentation]  create a vacation with starttime less than already existing  and endtime greater than existing one

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    appointment=${bool[1]}   waitlist=${bool[0]}

    ${start_time}=  db.subtract_timezone_time  ${tz}  0  30
    ${end_time}=    add_timezone_time  ${tz}  2  00  
    ${DAY6}=  db.add_timezone_date  ${tz}  6  
    ${desc}=    FakerLibrary.name
     ${resp}=  Create Vacation  ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${DAY5}  ${DAY5}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_ALREADY_NON_WORKING_DAY}



JD-TC-CreateVacation-UH8
    [Documentation]  create a past time  vacation for a valid provider on current day

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${start_time}=  db.subtract_timezone_time  ${tz}  0  05
    ${end_time}=    add_timezone_time  ${tz}  1  05  
    ${desc}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}   ${HOLIDAY_START_TIME_INCORRECT}

JD-TC-CreateVacation-UH9
    [Documentation]   Creating Vacation without login

    ${start_time}=  add_timezone_time  ${tz}   0  10
    # Set Suite Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  0  45   
    # Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
     ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${start_time}  ${end_time}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-CreateVacation-UH10
    [Documentation]    Take a appointment, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=4500   max=4999
    ${dep_desc1}=   FakerLibrary.word  
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
    Set Suite Variable  ${u_id4}  ${resp.json()}
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime13}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime13}
    ${eTime13}=  add_timezone_time  ${tz}  2  00  
    # Set Suite Variable   ${eTime13}
   
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime13}  ${eTime13}  1  5  ${lid}  ${u_id4}  ${s_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id}  ${resp.json()}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id4}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime13}  ${eTime13}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id1}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid6}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${pcid6}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id4}   ${pcid6}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}     
    ...   appointmentMode=${appointmentMode[0]}   consumerNote=${cnote}   apptBy=${apptBy[0]}  paymentStatus=${paymentStatus[0]}   phoneNumber=${CUSERNAME9}
   
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
     ${resp}=  Create Vacation  ${desc}  ${u_id4}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${sTime13}  ${eTime13}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id}    ${resp.json()['holidayId']}
    

    ${resp}=   Get Vacation   ${u_id4}
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
       

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}     
    ...   appointmentMode=${appointmentMode[0]}   consumerNote=${cnote}   apptBy=${apptBy[0]}  paymentStatus=${paymentStatus[0]}   phoneNumber=${CUSERNAME9}
   

# JD-TC-CreateVacation-UH13
#     [Documentation]    Create vacation, then try to take an appointment
    
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${desc}=   FakerLibrary.word
#     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
#     Set Suite Variable    ${CUR_DAY}
#     ${resp}=  Add To Waitlist By User  ${pcid6}  ${s_id}  ${que_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${pcid6}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   422
#     Should Be Equal As Strings    ${resp.json()}    ${HOLIDAY_NON_WORKING_DAY}


JD-TC-CreateVacation-UH11
    [Documentation]    Add consumer to Future day appointment, then try to create vacation
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime13}=  add_timezone_time  ${tz}  2  15  
    ${eTime13}=  add_timezone_time  ${tz}  3  00  
    ${FUTURE_Day}=  db.add_timezone_date  ${tz}  1  

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id4}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime13}  ${eTime13}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id1}   name=${schedule_name}   apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${FUTURE_Day}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME31}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid6}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid6}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  User Take Appointment For Consumer    ${u_id4}   ${cid6}  ${s_id}  ${sch_id1}  ${FUTURE_Day}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${sTime13}=  add_timezone_time  ${tz}  2  15  
    ${eTime13}=  add_timezone_time  ${tz}  3  00  
    ${descn}=    FakerLibrary.name
    ${resp}=  Create Vacation  ${descn}  ${p1_id}  ${recurringtype[1]}  ${list}  ${FUTURE_Day}  ${FUTURE_Day}  ${EMPTY}  ${start_time}  ${end_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id}    ${resp.json()['holidayId']}

    ${resp}=   Get Vacation   ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   1  id=${v_id}    description=${descn}      
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['repeatIntervals']}                   ${list}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['startDate']}                         ${FUTURE_Day}
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['terminator']['endDate']}             ${FUTURE_Day}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    Should Be Equal As Strings   ${resp.json()[1]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${FUTURE_Day}   appmtTime=${slot2}  appointmentEncId=${encId2}  apptStatus=${apptStatus[1]}     
    ...   appointmentMode=${appointmentMode[0]}   consumerNote=${cnote}   apptBy=${apptBy[0]}  paymentStatus=${paymentStatus[0]}   phoneNumber=${CUSERNAME31}
   

JD-TC-CreateVacation-UH12
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
    # Set Suite Variable   ${u_id3}   ${resp.json()[0]['id']}
    
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

    # ${queue_name}=  FakerLibrary.name
    # ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id3}  ${s_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${que_id3}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id3}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
   
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${desc}=    FakerLibrary.name
    ${Last_Day}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v4_id}    ${resp.json()['holidayId']}
    
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

   
    ${1_Day}=  db.add_timezone_date  ${tz}   2
    ${Last_Day1}=  db.add_timezone_date  ${tz}   4
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${1_Day}  ${Last_Day1}  ${EMPTY}  ${sTime1}  ${eTime1}  
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


   
JD-TC-CreateVacation-UH13
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
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${DAY1}  ${Last_Day}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v5_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation     ${u_id3}
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
    ${resp}=  Create Vacation   ${desc}  ${u_id3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${Last_Day1}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${HOLIDAY_ENDDATE_OVERLAPPED}
     
















   

*** Comments ***
JD-TC-CreateVacation-UH15
    [Documentation]    Create vacation, then try to Add consumer to Future Day appointment
    
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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_E1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_E1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}


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
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
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

    
    ${msg}=  FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${DAY}=  db.add_timezone_date  ${tz}  7  
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${p1_id}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid18}  ${wid[0]} 

    

    ${resp}=  Get consumer Waitlist By Id  ${cwid18}  ${p_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid18}  ${p_id}  ${purpose[0]}  ${cid1}
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
    ${resp}=  Create Vacation  ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v_id18}    ${resp.json()['holidayId']}
    
    ${resp}=  Get Vacation By Id  ${v_id18}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}     id=${v_id18}    description=${desc} 
    
    ${resp}=   Get Vacation    ${p1_id}
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
       
    ${resp}=  Activate Vacation    ${boolean[1]}   ${v_id18}
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

