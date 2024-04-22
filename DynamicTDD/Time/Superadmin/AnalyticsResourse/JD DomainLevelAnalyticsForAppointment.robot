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
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/iphoneKeywords.robot

*** Variables ***
@{multiples}  10  20  30   40   50

&{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24
...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
...  RESCHEDULED_APPMT=31  TOTAL_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34

&{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

&{donationAnalyticsMetrics}  DONATION_COUNT=48  DONATION_TOTAL=49  

&{consumerAnalyticsMetrics}   WEB_NEW_CONSUMER_COUNT=50  TELEGRAM_NEW_CONSUMER_COUNT=51  IOS_NEW_CONSUMER_COUNT=52  
... 	NEW_CONSUMER_TOTAL=54  TOTAL_BRAND_NEW_TRANSACTIONS=55  ANDROID_NEW_CONSUMER_COUNT=53



${digits}       0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}    0

*** Test Cases ***

JD-TC-DomainLevelAnalytics-1
    [Documentation]   take appointments for normal service and check domain level analytics

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id}  ${resp2.json()['serviceSector']['id']}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}025.${test_mail}  ${views}
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
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

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

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH0}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names}

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id0}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id0}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id0}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    comment  Add customers

    FOR   ${a}  IN RANGE   9
            
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

    comment  take appointment

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id0}
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
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    '${a}' > '${num_slots}'  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id0}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
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
    
    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WEB_APPMTS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_APPMT']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-DomainLevelAnalytics-2
    [Documentation]   take checkins for teleservice for a provider and check domain level analytics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERPH0}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${resp}=  Update Virtual Calling Mode   ${CallingModes[0]}  ${ZOOM_id0}   ACTIVE  ${instructions1}   ${CallingModes[1]}  ${PUSERPH0}   ACTIVE   ${instructions2}
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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}

    comment  Services for check-ins
    
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE3}=    Set Variable  ${ser_names[1]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE3}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s1}  ${resp.json()}

    comment  queue 1 for checkins

    
    ${resp}=  Create Sample Schedule   ${lid}  ${v_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}   ${v_s1}
    Should Be Equal As Strings  ${resp.status_code}  200

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
        ${resp}=  Take Virtual Service Appointment For Consumer  ${cid${a}}  ${v_s1}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id0}  ${apptfor}
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

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['TOTAL_FOR_TOKEN']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['WEB_TOKENS']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appmt_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Domain Level Analytics   metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_TOKEN']}    domainId=${domain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertualappmt_ids}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-DomainLevelAnalytics-3
    [Documentation]   take appointments for normal service and virtual service  and check domain level analytics for online appointments
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for  appointments

    ${SERVICE10}=    Set Variable  ${ser_names[2]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE6}=    Set Variable  ${ser_names[3]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${v_s2}  ${resp.json()}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id6}  ${v_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id6}   ${v_s2}
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
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id6}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
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
        ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v_s2}  ${sch_id1}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_id0}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['TELE_SERVICE_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-DomainLevelAnalytics-4
    [Documentation]   take appointments for prepayment service and check domain level analytics 
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for  appointments

    ${SERVICE11}=    Set Variable  ${ser_names[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id7}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id7}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id7}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s6_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s6_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s6_num_slots}=  Get Length  ${s6_slots}

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
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id7}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DomainLevelAnalytics-5
    [Documentation]   take appointments for a provider and check account level analytics for online appointments action changes(started,arrived)
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE10}=    Set Variable  ${ser_names[5]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[6]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}
    
    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id6}   ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id6}   ${s_id7}
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
    FOR   ${a}  IN RANGE   8

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id6}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   8
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id7}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # change_system_time  1  30

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
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

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['STARTED_TOKEN']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['CHECKED_IN_TOKEN']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-DomainLevelAnalytics-6
    [Documentation]   take appointments for a provider and check account level analytics for online tokens and appointments actions(completed,cancelled)
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins and appointments

    ${SERVICE10}=    Set Variable  ${ser_names[7]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[8]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}
  
    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id6}   ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id6}   ${s_id7}
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
    FOR   ${a}  IN RANGE   8

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id6}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   8
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id7}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
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

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['CHECKED_IN_TOKEN']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DomainLevelAnalytics-7
    [Documentation]     take appointments for a provider from consumer side and check domain level analytics after reschedule it
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins and appointments

    ${SERVICE10}=    Set Variable  ${ser_names[9]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[10]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id6}   ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id6}   ${s_id7}
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
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id6}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id7}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}
    ${DAY3}=  db.add_timezone_date  ${tz}  4  

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY3}  ${s_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s6_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s6_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s6_num_slots}=  Get Length  ${s6_slots}

    Log   ${appt_ids[0]}
    ${len}=  Get Length  ${appt_ids}
    ${len}=  Evaluate  ${len}/2
    ${len}=   Convert To Integer   ${len}

    FOR   ${a}  IN RANGE   ${len}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
     
        ${resp}=  Reschedule Appointment   ${pid}   ${appt_ids[${a}]}  ${s6_slots[${a}]}  ${DAY3}  ${sch_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Domain Level Analytics  metricId=${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 