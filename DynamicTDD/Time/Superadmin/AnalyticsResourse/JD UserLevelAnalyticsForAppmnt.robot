*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/iphoneKeywords.robot

*** Variables ***
@{multiples}  10  20  30   40   50

&{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

&{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24
...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
...  RESCHEDULED_APPMT=31  TOTAL_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34

&{donationAnalyticsMetrics}  DONATION_COUNT=48  DONATION_TOTAL=49  

&{consumerAnalyticsMetrics}   WEB_NEW_CONSUMER_COUNT=50  TELEGRAM_NEW_CONSUMER_COUNT=51  IOS_NEW_CONSUMER_COUNT=52  
... 	NEW_CONSUMER_TOTAL=54  TOTAL_BRAND_NEW_TRANSACTIONS=55  ANDROID_NEW_CONSUMER_COUNT=53



${digits}       0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}    0

*** Test Cases ***

JD-TC-UserLevelAnalytics-1
    [Documentation]   take appointments for normal service for a user and check user level analytics

    
    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+833550
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${accid}=   get_acc_id   ${PUSERNAME_E}
    Set Suite Variable  ${accid} 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_E}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_E}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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


    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${bs}=  FakerLibrary.bs
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

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+58738720
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    ${user_dis_name}=  FakerLibrary.last_name
    ${employee_id}=  FakerLibrary.last_name

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names}

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

    comment  schedule for appointment
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Update User Search Status  ${toggle[0]}  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User Search Status  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  True

    comment  Add customers

    FOR   ${a}  IN RANGE   5
            
        ${PO_Number}    Generate random string    7    0123456789
        ${cons_num}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
        ${firstname}=  FakerLibrary.first_name    
        ${lastname}=  FakerLibrary.last_name
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}

    ${appt_ids}=  Create List
    Set Suite Variable   ${appt_ids}
    FOR   ${a}  IN RANGE   5

        Exit For Loop If    '${a}' > '${num_slots}'  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  User Take Appointment For Consumer    ${u_id}  ${cid${a}}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${appt_ids}  ${apptid${a}}

    END    

    ${walkin_appmt_len}=   Evaluate  len($appt_ids)
    Set Suite Variable   ${walkin_appmt_len}
    sleep  02s   

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['TOTAL_APPMT']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['TOTAL_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-UserLevelAnalytics-2
    [Documentation]   take appointments for teleservice for a user and check user level analytics

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME_E}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${resp}=  Update Virtual Calling Mode   ${CallingModes[0]}  ${ZOOM_id0}   ACTIVE  ${instructions1}   ${CallingModes[1]}  ${PUSERNAME_E}   ACTIVE   ${instructions2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERNAME_E}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_accid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_accid0}

    comment  Services for check-ins
    
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_accid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE3}=    Set Variable  ${ser_names[1]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}

    ${resp}=  Create Virtual Service For User  ${SERVICE3}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s1}  ${resp.json()} 

    comment  queue 1 for checkins

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${v_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    comment  take appointment

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${v_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}

    ${appt_ids}=  Create List


    comment  Add customers

    FOR   ${a}  IN RANGE   10
            
        ${PO_Number}    Generate random string    7    0123456789
        ${cons_num}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
        ${firstname}=  FakerLibrary.first_name    
        ${lastname}=  FakerLibrary.last_name
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${walkin_vertualappmt_ids}=  Create List
    Set Suite Variable   ${walkin_vertualappmt_ids}

    FOR   ${a}  IN RANGE   9

        Exit For Loop If    '${a}' > '${num_slots}'  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=   User Take Virtual Service Appointment For Consumer   ${u_id}  ${cid${a}}  ${v_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id0}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
               
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        # ${resp}=  Get Appointment By Id   ${apptid${a}}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_vertualappmt_ids}
    ${walkin_vertualappmt_ids}=   Evaluate  len($walkin_vertualappmt_ids)
    Set Suite Variable   ${walkin_vertualappmt_ids}
    ${walkin_appmt_len1}=   Evaluate  ${walkin_appmt_len}+${walkin_vertualappmt_ids}
    Set Suite Variable   ${walkin_appmt_len1}

    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['TOTAL_APPMT']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['TOTAL_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_APPMT']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertualappmt_ids}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-UserLevelAnalytics-3
    [Documentation]   take appointments for normal service and virtual service  and check user level analytics for online appointments
    # [Setup]  Run Keywords  clear_queue  ${PUSERNAME_E}   AND  clear_appt_schedule   ${PUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for  appointments

    ${SERVICE10}=    Set Variable  ${ser_names[2]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE10}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id6}  ${resp.json()}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_accid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE6}=    Set Variable  ${ser_names[3]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create Virtual Service For User  ${SERVICE6}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${v_s2}  ${resp.json()}

    comment  schedule for appointment

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id6}  ${v_s2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s6_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s6_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s6_num_slots}=  Get Length  ${s6_slots}


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${v_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s7_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s7_num_slots}=  Get Length  ${s7_slots}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${online_appmts}=  Create List
    Set Suite Variable   ${online_appmts}

    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For User   ${accid}  ${s_id6}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${online_appmts}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appmts}
     ${online_vertualids}=  Create List
    Set Suite Variable   ${online_vertualids}

    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Virtual Service Appointment For User   ${accid}  ${v_s2}  ${sch_id1}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id0}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${online_vertualids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_vertualids}
    ${online_appmt_len3}=   Evaluate  len($online_appmts)+len($online_vertualids)
    Set Suite Variable   ${online_appmt_len3}


    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appmt_len3}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLevelAnalytics-4
    [Documentation]   take appointments for normal service  and check domain level analytics for online appointments action change
    # [Setup]  Run Keywords  clear_queue  ${PUSERNAME_E}   AND  clear_appt_schedule   ${PUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for  appointments

    ${SERVICE10}=    Set Variable  ${ser_names[4]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE10}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id6}  ${resp.json()}

    ${SERVICE11}=    Set Variable  ${ser_names[5]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE11}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id7}  ${resp.json()}

    comment  schedule for appointment

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id6}  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s6_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s6_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s6_num_slots}=  Get Length  ${s6_slots}


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s7_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s7_num_slots}=  Get Length  ${s7_slots}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For User   ${accid}  ${s_id6}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For User   ${accid}  ${s_id7}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log   ${appt_ids[0]}
    ${len}=  Get Length  ${appt_ids}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]} 

        ${resp}=  Appointment Action   ${apptStatus[2]}   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[2]}

    END


    FOR   ${a}  IN RANGE   ${len2}   ${len}  

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]} 

        ${resp}=  Appointment Action   ${apptStatus[3]}   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}

    END

    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['STARTED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['STARTED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLevelAnalytics-5
    [Documentation]   take appointments for normal service and virtual service  and check domain level analytics for online appointments action change
    # [Setup]  Run Keywords  clear_queue  ${PUSERNAME_E}   AND  clear_appt_schedule   ${PUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for  appointments

    ${SERVICE10}=    Set Variable  ${ser_names[6]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE10}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id6}  ${resp.json()}

    ${SERVICE11}=    Set Variable  ${ser_names[7]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE11}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id7}  ${resp.json()}

    comment  schedule for appointment

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  db.add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${maxval}=  Convert To Integer   ${delta/5}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule For User  ${u_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id6}  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s6_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s6_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s6_num_slots}=  Get Length  ${s6_slots}


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s7_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s7_num_slots}=  Get Length  ${s7_slots}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For User   ${accid}  ${s_id6}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For User   ${accid}  ${s_id7}  ${sch_id1}  ${DAY1}  ${cnote}  ${u_id}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${accid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log   ${appt_ids[0]}
    ${len}=  Get Length  ${appt_ids}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]} 

        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.word
        ${resp}=    Provider Cancel Appointment  ${appt_ids[${a}]}  ${reason}  ${msg}  ${DAY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    END


    FOR   ${a}  IN RANGE   ${len2}   ${len}  

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]} 

        ${resp}=  Appointment Action   ${apptStatus[6]}   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment Status   ${appt_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    END


    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
