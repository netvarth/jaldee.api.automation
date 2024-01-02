*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0
${count}       9
${def_amt}     0.0
${zero_value}     0
@{empty_list}


*** Test Cases ***

JD-TC-AccountLevelAnalytics-1

    [Documentation]   take walk-in appointments for a provider and check account level analytics for WALK_IN_APPMT and ARRIVED_APPMT

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}
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

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}


    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERPH0}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH0}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
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

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=40
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    ${sernames_len}=  Get Length  ${ser_names}

    Log List  ${ser_names}

    Set Suite Variable  ${ser_names}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id1}

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${parallel}=  FakerLibrary.Random Int  min=6  max=10

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment  Add customers
    # ${customers}=  Create List
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    comment  take appointment

    ${walkin_appt_ids}=  Create List
    Set Suite Variable   ${walkin_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id1}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}

       
    END

    Log List   ${walkin_appt_ids}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  10s
    sleep  01s
    # sleep  01m
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) 
    # Set Suite Variable   ${walkin_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-2

    [Documentation]   take walk-in appointments for a prepayment service for a provider and check account level analytics for WALK_IN_APPMT and ARRIVED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id2}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id2}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}   ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id1}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s2_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s2_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s2_num_slots}=  Get Length  ${s2_slots}

    ${walkin_prepay_appt_ids}=  Create List
    Set Suite Variable   ${walkin_prepay_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id2}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id1}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
            
        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id2}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${walkin_prepay_appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_prepay_appt_ids}

    sleep  01s
    # sleep  05m
    
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  10s
    # sleep  01s
    # sleep  01m
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids)
    # Set Suite Variable   ${walkin_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-3

    [Documentation]   take walk-in appointments for a virtual service for a provider and check account level analytics for WALK_IN_APPMT and CONFIRMED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE3}=    Set Variable  ${ser_names[2]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE3}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id1}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id1}   ${s_id2}  ${v_s1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${v_s1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id1}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{vs1_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${vs1_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${vs1_num_slots}=  Get Length  ${vs1_slots}
    
    ${walkin_vs_appt_ids}=  Create List
    Set Suite Variable   ${walkin_vs_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${v_s1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id1}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
        
        FOR   ${i}  IN RANGE   0   5

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
            
        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Virtual Service Appointment For Consumer with Mode  ${appointmentMode[0]}  ${cid${a}}  ${v_s1}  ${sch_id1}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${countryCodes[0]}${PUSERPH0}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${walkin_vs_appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_vs_appt_ids}

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # Set Suite Variable   ${walkin_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${confirmed_appt_len}=  Set Variable  ${{ len(@{vs_appt_ids}) }}
    # Set Suite Variable   ${confirmed_appt_len}

JD-TC-AccountLevelAnalytics-4

    [Documentation]   take online appointments for a provider and check account level analytics for ONLINE_APPMT and CONFIRMED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE4}=    Set Variable  ${ser_names[3]}
    ${s_id4}=  Create Sample Service  ${SERVICE4}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id4}

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id4}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  10   10   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id4}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id2}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s4_slots}=  Create List

    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1}  
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s4_slots_len}=  Get Length  ${s4_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${online_appt_ids}=  Create List
    Set Suite Variable   ${online_appt_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id2}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id2}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

    # Exit For Loop If    ${a}>=${s4_slots_len}  
   
        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id4}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        
    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m
    
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # ${online_appt_len}=  Evaluate  len($appt_ids) + len($prepay_appt_ids) + len($vs_appt_ids) - $walkin_appt_len
    ${online_appt_len}=  Evaluate  len($online_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-5

    [Documentation]   take online appointments for prepayment service for a provider and check account level analytics for ONLINE_APPMT and CONFIRMED_APPMT 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE5}=    Set Variable  ${ser_names[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id5}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}  ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id5}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id2}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s5_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1}  
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s5_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s5_slots_len}=  Get Length  ${s5_slots}
    
    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${online_prepay_appt_ids}=  Create List
    Set Suite Variable   ${online_prepay_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id2}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id2}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id5}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_prepay_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        
    END

    Log List   ${online_prepay_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # ${online_appt_len}=  Evaluate  len($appt_ids) + len($prepay_appt_ids) + len($vs_appt_ids) - $walkin_appt_len
    ${online_appt_len}=  Evaluate  len($online_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-6

    [Documentation]   take online appointments for virtual service for a provider and check account level analytics for ONLINE_APPMT and CONFIRMED_APPMT 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE6}=    Set Variable  ${ser_names[5]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE6}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}  ${s_id5}  ${v_s2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${v_s2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id2}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{vs2_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${vs2_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${vs2_slots_len}=  Get Length  ${vs2_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${online_vs_appt_ids}=  Create List
    Set Suite Variable   ${online_vs_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id2}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id2}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v_s2}  ${sch_id2}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${countryCodes[0]}${CUSERNAME${a}}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_vs_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
    
    END

    Log List   ${online_vs_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-7

    [Documentation]   take phone in appointments for a provider and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE7}=    Set Variable  ${ser_names[6]}
    ${s_id7}=  Create Sample Service  ${SERVICE7}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id7}

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id7}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id3}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  10   10   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id7}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${s_id7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id3}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s7_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s7_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s7_slots_len}=  Get Length  ${s7_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cons_phonein_appt_ids}=  Create List
    Set Suite Variable   ${cons_phonein_appt_ids}
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id3}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id3}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
 

        # ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Phonein Appointment For Provider   ${pid}  ${s_id7}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${cons_phonein_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${cons_phonein_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) 
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-8

    [Documentation]   consumer takes phone in appointment for prepayment service for a provider and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE8}=    Set Variable  ${ser_names[7]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id8}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id8}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id3}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id7}  ${s_id8}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${s_id8}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id3}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s8_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s8_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s8_slots_len}=  Get Length  ${s8_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phonein_prepay_appt_ids}=  Create List
    Set Suite Variable   ${phonein_prepay_appt_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id3}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id3}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Phonein Appointment For Provider   ${pid}  ${s_id8}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${phonein_prepay_appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${phonein_prepay_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids)
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-9

    [Documentation]   take phone in appointments for virtual service for a provider and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE9}=    Set Variable  ${ser_names[8]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE9}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id3}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id7}  ${s_id8}  ${v_s3}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${v_s3}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id3}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{vs3_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${vs3_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${vs3_slots_len}=  Get Length  ${vs3_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cons_phonein_vs_appt_ids}=  Create List
    Set Suite Variable   ${cons_phonein_vs_appt_ids}
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id3}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id3}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Phone-in Virtual Service Appointment For Provider   ${pid}  ${v_s3}  ${sch_id3}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${countryCodes[0]}${CUSERNAME${a}}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${cons_phonein_vs_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200  

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${cons_phonein_vs_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids)
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-10

    [Documentation]   provider takes phone in appointments for a consumer and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE10}=    Set Variable  ${ser_names[9]}
    ${s_id10}=  Create Sample Service  ${SERVICE10}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id10}

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id10}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id4}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id4}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  10    10   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id10}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id10}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id4}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s10_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s10_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s10_slots_len}=  Get Length  ${s10_slots}

    ${pro_phonein_appt_ids}=  Create List
    Set Suite Variable   ${pro_phonein_appt_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id10}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id4}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid${a}}  ${s_id10}  ${sch_id4}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${pro_phonein_appt_ids}  ${apptid${a}}        

    END

    Log List   ${pro_phonein_appt_ids}

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids)
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-11

    [Documentation]   provider takes phone in appointments for a consumer for a service with prepayment and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE11}=    Set Variable  ${ser_names[10]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id11}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id11}

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id4}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id10}  ${s_id11}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id11}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id4}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s11_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s11_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s11_slots_len}=  Get Length  ${s11_slots}

    ${pro_prepay_phonein_appt_ids}=  Create List
    Set Suite Variable   ${pro_prepay_phonein_appt_ids}
    
    FOR   ${a}  IN RANGE   ${count}
    
        # Exit For Loop If    ${a}>=${s11_slots_len}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${s_id11}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id4}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid${a}}  ${s_id11}  ${sch_id4}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[1]}

        Append To List   ${pro_prepay_phonein_appt_ids}  ${apptid${a}}        

    END

    Log List   ${pro_prepay_phonein_appt_ids}

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_prepay_phonein_appt_ids)
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-12

    [Documentation]   provider takes phone in appointments for a virtual service for a consumer and check account level analytics for PHONE_APPMT and CONFIRMED_APPMT

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE12}=    Set Variable  ${ser_names[11]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE12}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s4}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id4}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id10}  ${s_id11}  ${v_s4}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${v_s4}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id4}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{vs4_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${vs4_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${vs4_slots_len}=  Get Length  ${vs4_slots}

    ${pro_vs_phonein_appt_ids}=  Create List
    Set Suite Variable   ${pro_vs_phonein_appt_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id4}  ${DAY1}  ${v_s4}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id4}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        # ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid${a}}  ${v_s4}  ${sch_id4}  ${DAY1}  ${cnote}  ${apptfor}
        ${resp}=  Take Virtual Service Appointment For Consumer with Mode  ${appointmentMode[1]}  ${cid${a}}  ${v_s4}  ${sch_id4}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${countryCodes[0]}${PUSERPH0}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${pro_vs_phonein_appt_ids}  ${apptid${a}}        

    END

    Log List   ${pro_vs_phonein_appt_ids}

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    ${phonein_appt_len}=  Evaluate  len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_prepay_phonein_appt_ids) + len($pro_vs_phonein_appt_ids)
    # Set Suite Variable   ${phonein_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['PHONE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['PHONE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $phonein_appt_len
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-13

    [Documentation]   make prepayments and check PRE_PAYMENT_COUNT and PRE_PAYMENT_TOTAL metrics.

    Log List   ${online_prepay_appt_ids}
    Log List   ${online_appt_ids}
    

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable   ${cid}   ${resp.json()['id']}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${online_prepay_appt_ids[${a}]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}
        Set Test Variable   ${appt_time}   ${resp.json()['appmtTime']}
        Set Test Variable   ${p1_sid1}   ${resp.json()['service']['id']}
        Set Test Variable   ${sch_id1}   ${resp.json()['schedule']['id']}

        ${cnote}=   FakerLibrary.word
        ${EMPTY_List}=  Create List

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${appt_time}
        ${apptfor}=   Create List  ${apptfor1}

        ${resp}=   Appointment AdvancePayment Details   ${pid}  ${p1_sid1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${pre_amt}   ${resp.json()['amountRequiredNow']}

        # ${resp}=  Get consumer Appointment By Id  ${pid}  ${online_prepay_appt_ids[${a}]}  
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # # Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}
        # # Set Test Variable   ${pre_amt}   ${resp.json()['service']['minPrePaymentAmount']}
        # Set Test Variable   ${p1_sid1}   ${resp.json()['service']['id']}

        # ${resp}=  Make payment Consumer Mock  ${pre_amt}  ${bool[1]}  ${online_prepay_appt_ids[${a}]}  ${pid}  ${purpose[0]}  ${cid}
        ${resp}=  Make payment Consumer Mock  ${pid}  ${pre_amt}  ${purpose[0]}  ${online_prepay_appt_ids[${a}]}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep  02s

        ${resp}=  Get consumer Appointment By Id  ${pid}  ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}
        # Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        Append To List   ${online_appt_ids}  ${online_prepay_appt_ids[${a}]}

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${j}  IN RANGE   ${count}

        ${resp}=  Get Appointment By Id  ${online_prepay_appt_ids[${j}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}
        

    END

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${pre_amt}  ${count}

    ${tot_pre_amt}=  Evaluate  $pre_amt * float($count)
    
    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${tot_pre_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) + len($online_prepay_appt_ids)
    Log Many   len${online_appt_ids}  len${online_vs_appt_ids}  len${cons_phonein_appt_ids}    len${cons_phonein_vs_appt_ids}  len${pro_phonein_appt_ids}  len${pro_vs_phonein_appt_ids}  len${pro_prepay_phonein_appt_ids}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) + len($pro_prepay_phonein_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-AccountLevelAnalytics-14

    [Documentation]   change status from confirmed to arrived and check CONFIRMED_APPMT and ARRIVED_APPMT metrics
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${tot_prepay_appt_len}=  Get Length  ${prepay_appt_ids}
    # ${tot_apt_len}=  Get Length  ${appt_ids}

    ${prepay_count}=  Get Length  ${online_prepay_appt_ids}
    Set Suite Variable   ${prepay_count}
    Log List  ${online_prepay_appt_ids}

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response   ${resp}  uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[1]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
        ${resp}=  Appointment Action   ${apptStatus[2]}   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    END

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[2]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${online_prepay_appt_ids[${a}]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
    END

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    # Log Many  ${walkin_appt_len}  ${a}
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids)
    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) + len($pro_prepay_phonein_appt_ids) - len($online_prepay_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) + len($online_prepay_appt_ids)
    # Set Suite Variable   ${arrived_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-15
    [Documentation]   change status from arrived to started and check CONFIRMED_APPMT, ARRIVED_APPMT and STARTED_APPMT metrics
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${tot_prepay_appt_len}=  Get Length  ${prepay_appt_ids}
    # ${tot_apt_len}=  Get Length  ${appt_ids}

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response   ${resp}  uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[2]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
        ${resp}=  Appointment Action   ${apptStatus[3]}   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${online_prepay_appt_ids[${a}]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    
    ${online_prepay_len}=  Get Length  ${online_prepay_appt_ids}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_prepay_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-16
    [Documentation]   change status from started to Completed and check STARTED_APPMT and COMPLETETED_APPMT metrics
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${tot_prepay_appt_len}=  Get Length  ${prepay_appt_ids}
    # ${tot_apt_len}=  Get Length  ${appt_ids}

    ${completed_online_appt_ids}=  Create List
    Set Suite Variable   ${completed_online_appt_ids}

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response   ${resp}  uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
        ${resp}=  Appointment Action   ${apptStatus[6]}   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

        Append To List   ${completed_online_appt_ids}  ${online_prepay_appt_ids[${a}]}

    END

    FOR   ${a}  IN RANGE   ${prepay_count}

        ${resp}=  Get Appointment By Id   ${online_prepay_appt_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${online_prepay_appt_ids[${a}]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

    END

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    
    ${online_prepay_len}=  Get Length  ${online_prepay_appt_ids}
    # Set Suite Variable   ${online_prepay_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${zero_value}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${completed_appt_len}=  Get Length  ${completed_online_appt_ids}
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${completed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-17
    [Documentation]   consumer cancels confirmed appointment and check CONFIRMED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE13}=    Set Variable  ${ser_names[12]}
    ${s_id13}=  Create Sample Service  ${SERVICE13}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id13}

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id13}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id5}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  5    5   ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id13}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id5}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s13_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s13_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    # END
    # ${s13_slots_len}=  Get Length  ${s13_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id5}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id5}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
    
        # Exit For Loop If    ${a}>=${s13_slots_len}  

        # ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id13}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cancelled_online_appt_ids}=  Create List
    Set Suite Variable   ${cancelled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        # Exit For Loop If    ${a}>=${s13_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        
        ${resp}=  Cancel Appointment By Consumer  ${apptid${a}}   ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}

        # Exit For Loop If    ${a}>=${s13_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Get Length  ${cancelled_online_appt_ids}
    Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - $cancelled_appt_len
    Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
JD-TC-AccountLevelAnalytics-18

    [Documentation]   consumer cancels appointment in prepayment pending state and check ONLINE_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE14}=    Set Variable  ${ser_names[13]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id14}=  Create Sample Service with Prepayment  ${SERVICE14}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id14}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}  ${s_id14}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id14}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s14_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s14_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s14_slots_len}=  Get Length  ${s14_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s14_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id14}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_prepay_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_prepay_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) 
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cancelled_online_prepay_appt_ids}=  Create List
    Set Suite Variable   ${cancelled_online_prepay_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[0]}
        
        ${resp}=  Cancel Appointment By Consumer  ${apptid${a}}   ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_online_prepay_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s14_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m
    sleep  1s
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-19

    [Documentation]   provider cancel's an confirmed appointment and check CONFIRMED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE15}=    Set Variable  ${ser_names[14]}
    ${s_id15}=  Create Sample Service  ${SERVICE15}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id15}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}  ${s_id14}  ${s_id15}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id15}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s15_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s15_slots_len}=  Get Length  ${s15_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s15_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s15_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id15}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    # ${cancelled_appt_ids}=  Create List
    # Set Suite Variable   ${cancelled_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s15_slots_len}  

        # ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_online_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

        # ${resp}=  Consumer Logout
        # Log  ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200

    END

    # ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s15_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m
    sleep  1s

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-20

    [Documentation]   change status of online appt from arrived to cancelled and check ARRIVED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE16}=    Set Variable  ${ser_names[15]}
    ${s_id16}=  Create Sample Service  ${SERVICE16}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id16}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id16}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s16_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s16_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s16_slots_len}=  Get Length  ${s16_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s16_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id16}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${arrived_count}=  Set Variable  ${0}

    ${arrived_appt_ids}=  Create List
    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response   ${resp}  uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[1]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
            
        ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${arrived_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

        # ${arrived_count}=  Evaluate  $arrived_count + 1

    END
    
    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    END

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($arrived_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) + len($arrived_appt_ids)
    # Set Suite Variable   ${arrived_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${cancelled_appt_ids}=  Create List
    # Set Suite Variable   ${cancelled_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${resp}=  Cancel Appointment By Consumer  ${apptid${a}}   ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m
    sleep  1s
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # Set Suite Variable   ${arrived_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-21
    [Documentation]   cancel walkin checkins and check ARRIVED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE17}=    Set Variable  ${ser_names[16]}
    ${s_id17}=  Create Sample Service  ${SERVICE17}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id17}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id17}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id5}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s17_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s17_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    # END
    # ${s17_slots_len}=  Get Length  ${s17_slots}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id17}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleId=${sch_id5}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END
            
        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

    
        # Exit For Loop If    ${a}>=${s17_slots_len}  

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        # Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        # ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s17_slots[${a}]}
        # ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id17}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_appt_ids}

    sleep  01s
    # sleep  10m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # Set Suite Variable   ${walkin_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${cancelled_walkin_appt_ids}=  Create List
    Set Suite Variable   ${cancelled_walkin_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        # Exit For Loop If    ${a}>=${s17_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_walkin_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    FOR   ${a}  IN RANGE   ${count}

        # Exit For Loop If    ${a}>=${s17_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m
    sleep  1s

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    

JD-TC-AccountLevelAnalytics-22

    [Documentation]   change status from confirmed to rejected and check CONFIRMED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id13}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id5}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s13_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s13_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    # END
    # ${s13_slots_len}=  Get Length  ${s13_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Get Appointment Slots By Schedule and Date    ${sch_id5}    ${DAY1}   ${pid}    
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Verify Response  ${resp}  scheduleId=${sch_id5}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}

        FOR   ${i}  IN RANGE   0   3

            ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
            IF  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   
                Exit For Loop
            END

        END

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${resp.json()['availableSlots'][${index}]['time']}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id13}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_online_appt_ids}=  Create List
    Set Suite Variable   ${rejected_online_appt_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        # Exit For Loop If    ${a}>=${s13_slots_len}  
        
        sleep  1s
        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Reject Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rejected_online_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    FOR   ${a}  IN RANGE   ${count}

        # Exit For Loop If    ${a}>=${s13_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    # sleep  10m
    sleep  1s
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # ${cancelled_appt_len}=  Get Length  ${cancelled_appt_ids}
    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) 
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_appt_len}=  Evaluate  len($rejected_online_appt_ids)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rejected_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    

# *** comment ***

JD-TC-AccountLevelAnalytics-23
    [Documentation]   change status from arrived to rejected and check ARRIVED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id14}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s14_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s14_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s14_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    ${s14_slots_len}=  Get Length  ${s14_slots}

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s14_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id14}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}
        

    END

    Log List   ${walkin_appt_ids}

    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    Set Suite Variable   ${walkin_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_walkin_appt_ids}=  Create List
    Set Suite Variable   ${rejected_walkin_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=   Reject Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rejected_walkin_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s14_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # ${cancelled_appt_len}=  Get Length  ${cancelled_appt_ids}
    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) 
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_appt_len}=  Evaluate  len($rejected_online_appt_ids) + len($rejected_walkin_appt_ids)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rejected_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    


# JD-TC-AccountLevelAnalytics-24

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
#     [Documentation]   change status from completed to rejected and check COMPLETETED_APPMT and CANCELLED_APPMT metrics
        # Cannot change appointment status from Completed to Rejected.
#     ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id15}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id5}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s15_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#         IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
#             ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
#             FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
#                 Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#             END
#         END
#     END
#     ${s15_slots_len}=  Get Length  ${s15_slots}

#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s15_slots_len}  

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
#         Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s15_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id15}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Suite Variable  ${apptid${a}}  ${apptid}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}
        

#     END

#     Log List   ${walkin_appt_ids}

#     # sleep  01s
#     # sleep  10m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids)
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${completed_walkin_appt_ids}=  Create List
#     Set Suite Variable   ${completed_walkin_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${apptid${a}}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

#         Append To List   ${completed_walkin_appt_ids}  ${apptid${a}}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

#     END

#     # sleep  01s
#     # sleep  10m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

    
#     ${completed_appt_len}=  Evaluate  len($completed_online_appt_ids) + len($completed_walkin_appt_ids)
#     # Set Suite Variable   ${started_appt_len}
#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids) - len($completed_walkin_appt_ids)
#     # Set Suite Variable   ${arrived_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${completed_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
#     # ${cancelled_appt_ids}=  Create List
#     # Set Suite Variable   ${cancelled_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s15_slots_len}  

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}
        
#         ${reason}=  Random Element  ${cancelReason}
#         ${msg}=   FakerLibrary.sentence
#         ${resp}=   Reject Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Append To List   ${rejected_walkin_appt_ids}  ${apptid${a}}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

#         # Append To List   ${completed_appt_ids}  ${apptid${a}}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

#     END

#     # sleep  10m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) 
#     # Set Suite Variable   ${cancelled_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['COMPLETETED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${rejected_appt_len}=  Evaluate  len($rejected_online_appt_ids) + len($rejected_walkin_appt_ids)

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rejected_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-25
    [Documentation]   change status from cancelled to confirmed and check CONFIRMED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id16}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s16_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s16_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s16_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    ${s16_slots_len}=  Get Length  ${s16_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s16_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id16}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_online_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) 

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_ids}=  Create List
    Set Suite Variable   ${confirmed_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}
        
        ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${confirmed_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    END

    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-26
    [Documentation]   change status from cancelled to arrived and check ARRIVED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE13}=    Set Variable  ${ser_names[22]}
    ${s_id14}=  Create Sample Service  ${SERVICE13}
    Set Suite Variable  ${s_id14}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id14}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s14_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s14_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s14_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    ${s14_slots_len}=  Get Length  ${s14_slots}

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s14_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id14}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Test Variable  ${apptid${a}}  ${apptid}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_appt_ids}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # Set Suite Variable   ${walkin_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    # ${cancelled_walkin_appt_ids}=  Create List
    # Set Suite Variable   ${cancelled_walkin_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_walkin_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s14_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_ids}=  Create List
    Set Suite Variable   ${arrived_appt_ids}
    ${confirmed_appt_ids}=  Create List
    Set Suite Variable   ${confirmed_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s14_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}
        
        ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${confirmed_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

        ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${arrived_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    END

    Log List  ${arrived_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s14_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    END

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($arrived_appt_ids) - len($confirmed_appt_ids)
    # ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids) - len($arrived_appt_ids)
    
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids) + len($arrived_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    


JD-TC-AccountLevelAnalytics-27
    [Documentation]   change status from cancelled to started and check STARTED_APPMT and CANCELLED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id15}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s15_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    ${s15_slots_len}=  Get Length  ${s15_slots}

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s15_slots_len}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s15_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id15}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}

    END

    Log List   ${walkin_appt_ids}

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    
    ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
    # Set Suite Variable   ${walkin_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) 
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s15_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${cancelled_walkin_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s15_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    END

    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids) - len($arrived_appt_ids)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) + len($arrived_appt_ids) - len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids)
    # ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids) + len($arrived_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${started_appt_ids}=  Create List
    Set Suite Variable   ${started_appt_ids}

    ${confirmed_appt_ids}=  Create List
    Set Suite Variable   ${confirmed_appt_ids}

    ${arrived_appt_ids}=  Create List
    Set Suite Variable   ${arrived_appt_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s15_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

        ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${confirmed_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

        ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${arrived_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
        
        ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${started_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END

    Log List  ${started_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s15_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END
    
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids) - len($arrived_appt_ids) - len($started_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${started_appt_len}=  Get Length  ${started_appt_ids}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    


JD-TC-AccountLevelAnalytics-28
    [Documentation]   change status from rejected to confirmed and check CONFIRMED_APPMT and REJECTED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    # ${SERVICE12}=    Set Variable  ${ser_names[11]}
    # ${s_id16}=  Create Sample Service  ${SERVICE12}
    # Set Suite Variable  ${s_id16}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id15}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id5}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s16_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s16_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s16_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    ${s16_slots_len}=  Get Length  ${s16_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s16_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id15}  ${sch_id5}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_online_appt_ids1}=  Create List
    Set Suite Variable   ${rejected_online_appt_ids1}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
        
        ${reason}=  Random Element  ${cancelReason}
        ${msg}=   FakerLibrary.sentence
        Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
        ${resp}=    Reject Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rejected_online_appt_ids1}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    END

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # ${cancelled_appt_len}=  Get Length  ${cancelled_appt_ids}
    # ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids)
    # ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) + len($rejected_online_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids)
    # ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids)
    # Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_appt_len}=  Evaluate  len($rejected_online_appt_ids) + len($rejected_walkin_appt_ids) + len($rejected_online_appt_ids1)

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rejected_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${confirmed_appt_ids}=  Create List
    # Set Suite Variable   ${confirmed_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s16_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}
        
        ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${confirmed_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    END

    Set Suite Variable   ${confirmed_appt_ids}

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s16_slots_len}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    END

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) - len($confirmed_appt_ids)
    # ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) + len($rejected_online_appt_ids) + len($rejected_walkin_appt_ids) - len($confirmed_appt_ids)
    # Set Suite Variable   ${cancelled_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids1) + len($confirmed_appt_ids)/2

    ${confirmed_appt_len}=    Convert To Integer    ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rejected_appt_len}=  Evaluate  len($rejected_online_appt_ids1) + len($rejected_walkin_appt_ids) 

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['REJECTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rejected_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-29
    [Documentation]   consumer reschedules an appointment taken from consumer side (online appointment) to another slot on the same day and check CONFIRMED_APPMT and RESCHEDULED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE18}=    Set Variable  ${ser_names[17]}
    ${s_id18}=  Create Sample Service  ${SERVICE18}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id18}

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id18}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id6}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id18}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id18}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s18_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s18_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s18_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${s18_slots}
    ${s18_slots_len}=  Get Length  ${s18_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s18_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s18_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id18}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id18}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s18_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s18_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${s18_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${s18_slots}
    ${s18_slots_len}=  Get Length  ${s18_slots}
    ${reversed_s18_slots}=  Copy List  ${s18_slots}
    Reverse List 	${reversed_s18_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${s18_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s14_slots[${a}]}
        # ${apptfor}=   Create List  ${apptfor1}

        # ${cnote}=   FakerLibrary.name
        # ${resp}=   Take Appointment For Provider   ${pid}  ${s_id14}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        # Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=  Reschedule Appointment   ${pid}   ${apptid${a}}  ${reversed_s18_slots[${a}]}  ${DAY1}  ${sch_id6}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-30
    [Documentation]   consumer reschedules an appointment taken from consumer side (online appointment) to another slot on the same day in a different schedule and check CONFIRMED_APPMT and RESCHEDULED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${SERVICE19}=    Set Variable  ${ser_names[25]}
    ${s_id19}=  Create Sample Service  ${SERVICE19}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id19}

    # ${SERVICE16}=    Set Variable  ${ser_names[15]}
    # ${s_id16}=  Create Sample Service  ${SERVICE16}
    # Set Suite Variable  ${s_id16}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    ...  ${s_id18}  ${s_id19}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id19}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id7}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id7}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    ...  ${s_id19}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id19}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{sch6_s19_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${sch6_s19_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${sch6_s19_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${sch6_s19_slots}
    ${sch6s19_slots_len}=  Get Length  ${sch6_s19_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${sch6s19_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${sch6_s19_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id19}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id7}  ${DAY1}  ${s_id19}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id7}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{sch7_s19_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${sch7_s19_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${sch7_s19_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${sch7_s19_slots}
    ${sch7s19_slots_len}=  Get Length  ${sch7_s19_slots}
    # ${reversed_s15_slots}=  Copy List  ${s15_slots}
    # Reverse List 	${reversed_s15_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${sch7s19_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s14_slots[${a}]}
        # ${apptfor}=   Create List  ${apptfor1}

        # ${cnote}=   FakerLibrary.name
        # ${resp}=   Take Appointment For Provider   ${pid}  ${s_id14}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        # Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=  Reschedule Appointment   ${pid}   ${apptid${a}}  ${sch7_s19_slots[${a}]}  ${DAY1}  ${sch_id7}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-AccountLevelAnalytics-31
    [Documentation]   consumer reschedules an appointment taken from consumer side (online appointment) to another day and check CONFIRMED_APPMT and RESCHEDULED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${SERVICE20}=    Set Variable  ${ser_names[19]}
    ${s_id20}=  Create Sample Service  ${SERVICE20}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id20}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    ...  ${s_id18}  ${s_id19}  ${s_id20}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Update Appointment Schedule  ${sch_id7}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    # ...  ${s_id15}  ${s_id16}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id20}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d1_s20_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d1_s20_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d1_s20_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${d1_s20_slots}
    ${d1_s20_slots_len}=  Get Length  ${d1_s20_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d1_s20_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${d1_s20_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id20}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY2}  ${s_id20}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d2_s20_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d2_s20_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d2_s20_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${d2_s20_slots}
    ${d2_s20_slots_len}=  Get Length  ${d2_s20_slots}
    # ${reversed_s15_slots}=  Copy List  ${s15_slots}
    # Reverse List 	${reversed_s15_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d2_s20_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        # ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s14_slots[${a}]}
        # ${apptfor}=   Create List  ${apptfor1}

        # ${cnote}=   FakerLibrary.name
        # ${resp}=   Take Appointment For Provider   ${pid}  ${s_id14}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        # Set Suite Variable  ${apptid${a}}  ${apptid1}

        ${resp}=  Reschedule Appointment   ${pid}   ${apptid${a}}  ${d2_s20_slots[${a}]}  ${DAY2}  ${sch_id6}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY2}



JD-TC-AccountLevelAnalytics-32
    [Documentation]   provider reschedules an appointment taken from consumer side (online appointment) to another day and check CONFIRMED_APPMT and RESCHEDULED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${SERVICE21}=    Set Variable  ${ser_names[20]}
    ${s_id21}=  Create Sample Service  ${SERVICE21}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id21}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    ...  ${s_id18}  ${s_id19}  ${s_id20}  ${s_id21}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d1_s21_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d1_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d1_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${d1_s21_slots}
    ${d1_s21_slots_len}=  Get Length  ${d1_s21_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d1_s21_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${d1_s21_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id21}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY2}  ${s_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d2_s21_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d2_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d2_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${d2_s21_slots}
    ${d2_s21_slots_len}=  Get Length  ${d2_s21_slots}
    # ${reversed_s15_slots}=  Copy List  ${s15_slots}
    # Reverse List 	${reversed_s15_slots}

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d2_s21_slots_len}  

        ${resp}=  Reschedule Consumer Appointment   ${apptid${a}}  ${d2_s21_slots[${a}]}  ${DAY2}  ${sch_id6}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get Appointment By Id  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY2}
    


JD-TC-AccountLevelAnalytics-33
    [Documentation]   Reschedule an appointment taken from provider side (walkin appointment) and check ARRIVED_APPMT and RESCHEDULED_APPMT metrics

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${SERVICE22}=    Set Variable  ${ser_names[21]}
    # ${s_id22}=  Create Sample Service  ${SERVICE22}  maxBookingsAllowed=10
    ${s_id22}=  Create Sample Service  ${SERVICE22}
    Set Suite Variable  ${s_id22}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    ...  ${s_id18}  ${s_id19}  ${s_id20}  ${s_id21}  ${s_id22}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id22}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d1_s22_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d1_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d1_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${d1_s22_slots}
    ${d1_s22_slots_len}=  Get Length  ${d1_s22_slots}

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d1_s22_slots_len}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${resp1}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Suite Variable  ${cid${a}}   ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${a}}  ${resp.json()[0]['id']}
        END

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id22}  ${sch_id6}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${walkin_appt_ids}  ${apptid${a}}

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY2}  ${s_id21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d1_s22_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d2_s21_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d1_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${d1_s22_slots}
    ${d1_s22_slots_len}=  Get Length  ${d1_s22_slots}
    # ${reversed_s15_slots}=  Copy List  ${s15_slots}
    # Reverse List 	${reversed_s15_slots}

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d1_s22_slots_len}  

        ${resp}=  Reschedule Consumer Appointment   ${apptid${a}}  ${d1_s22_slots[${a}]}  ${DAY2}  ${sch_id6}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get Appointment By Id  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY2}



JD-TC-AccountLevelAnalytics-34
    [Documentation]   Consumer Reschedules a started appointment taken from consumer side (online appointment) and check ONLINE_APPMT, CONFIRMED_APPMT, STARTED_APPMT and RESCHEDULED_APPMT metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    # ${SERVICE22}=    Set Variable  ${ser_names[21]}
    # ${s_id22}=  Create Sample Service  ${SERVICE22}  maxBookingsAllowed=10
    # Set Suite Variable  ${s_id22}

    ${resp}=  Get Appointment Schedule ById  ${sch_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Update Appointment Schedule  ${sch_id6}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    # ...  ${s_id18}  ${s_id19}  ${s_id20}  ${s_id21}  ${s_id22}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Update Appointment Schedule  ${sch_id7}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
    # ...  ${s_id15}  ${s_id16}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedule ById  ${sch_id7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY1}  ${s_id22}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d1_s22_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d1_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d1_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List  ${d1_s22_slots}
    ${d1_s22_slots_len}=  Get Length  ${d1_s22_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d1_s22_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${d1_s22_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id22}  ${sch_id6}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${online_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids)
    # Set Suite Variable   ${online_appt_len}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${d1_s22_slots_len}  

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response   ${resp}  uid=${apptid${a}}  apptStatus=${apptStatus[1]}
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
        ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${started_appt_ids}  ${apptid${a}}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Appointment By Id   ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    END

    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  01s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    
    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${started_appt_len}=  Get Length  ${started_appt_ids}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id6}  ${DAY2}  ${s_id20}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id6}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{d2_s22_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        # Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${d2_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0
            ${noOfAvailbleSlots}=  Set Variable   ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR  ${j}  IN RANGE  ${noOfAvailbleSlots}
                Append To List   ${d2_s22_slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
    END
    Log List   ${d2_s22_slots}
    ${d2_s22_slots_len}=  Get Length  ${d2_s22_slots}
    # ${reversed_s15_slots}=  Copy List  ${s15_slots}
    # Reverse List 	${reversed_s15_slots}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${rescheduled_online_appt_ids}=  Create List
    Set Suite Variable   ${rescheduled_online_appt_ids}
    FOR   ${a}  IN RANGE   ${count}
    
        Exit For Loop If    ${a}>=${d2_s22_slots_len}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${resp}=  Reschedule Appointment   ${pid}   ${apptid${a}}  ${d2_s22_slots[${a}]}  ${DAY2}  ${sch_id6}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_online_appt_ids}  ${apptid${a}}

        ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_appt_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ONLINE_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  len($online_appt_ids) + len($online_vs_appt_ids) + len($cons_phonein_appt_ids) + len($cons_phonein_vs_appt_ids) + len($pro_phonein_appt_ids) + len($pro_vs_phonein_appt_ids) - len($cancelled_online_appt_ids) - len($rejected_online_appt_ids) + len($confirmed_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_appt_len}=  Evaluate  len($rescheduled_online_appt_ids)
    
    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}  ${DAY1}  ${DAY2}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['RESCHEDULED_APPMT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${rescheduled_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY2}

*** comment ***
JD-TC-AccountLevelAnalytics-35
    [Documentation]   Provider Reschedules a started appointment taken from consumer side (online appointment) and check ONLINE_APPMT, CONFIRMED_APPMT, STARTED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-36
    [Documentation]   Provider Reschedules a started appointment taken from provider side (walkin appointment) and check WALK_IN_APPMT, ARRIVED_APPMT, STARTED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-37
    [Documentation]   Reschedule a completed appointment taken from consumer side (online appointment) and check ONLINE_APPMT, CONFIRMED_APPMT, COMPLETETED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-38
    [Documentation]   Reschedule a completed appointment taken from provider side (walkin appointment) and check WALK_IN_APPMT, ARRIVED_APPMT, COMPLETETED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-39
    [Documentation]   Reschedule a cancelled appointment taken from consumer side (online appointment) and check ONLINE_APPMT, CONFIRMED_APPMT, STARTED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-40
    [Documentation]   Reschedule a cancelled appointment taken from provider side (walkin appointment) and check WALK_IN_APPMT, ARRIVED_APPMT, STARTED_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-41
    [Documentation]   Reschedule a prepayment pending appointment and check ONLINE_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-42
    [Documentation]   Reschedule an appointment after prepayment and check ONLINE_APPMT and RESCHEDULED_APPMT metrics



JD-TC-AccountLevelAnalytics-43
    [Documentation]   take a future appointment from consumer side and check ONLINE_APPMT and CONFIRMED_APPMT metrics for the future date



JD-TC-AccountLevelAnalytics-44
    [Documentation]   take a future appointment from provider side and check WALK_IN_APPMT and CONFIRMED_APPMT metrics for the future date
    
    

    


*** Comment ***




    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id1}
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{s1_slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${count}
    #     ${index}=   FakerLibrary.Random Int  min=0  max=${no_of_slots-1} 
    #     Run Keyword If  ${resp.json()['availableSlots'][${index}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${index}]['time']}
    # END
    # ${s1_slots_len}=  Get Length  ${s1_slots}

    # ${walkin_appt_ids}=  Create List
    # Set Suite Variable   ${walkin_appt_ids}
    # FOR   ${a}  IN RANGE   ${count}

    #     Exit For Loop If    ${a}>=${s1_slots_len}  

    #     ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
    #     ${apptfor}=   Create List  ${apptfor1}
            
    #     ${cnote}=   FakerLibrary.word
    #     ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
            
    #     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    #     Set Suite Variable  ${apptid${a}}  ${apptid[0]}

    #     Append To List   ${walkin_appt_ids}  ${apptid${a}}

    # END

    # Log List   ${walkin_appt_ids}


# JD-TC-AccountLevelAnalytics-22
#     [Documentation]   change status from started to cancelled and check STARTED_APPMT and CANCELLED_APPMT metrics

#     ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     # ${resp}=  Update Appointment Schedule  ${sch_id5}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
#     # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
#     # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${resp.json()['parallelServing']}    ${resp.json()['consumerParallelServing']}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
#     # ...  ${s_id13}  ${s_id14}  ${s_id15}  ${s_id16}  ${s_id17}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     # ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id13}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id5}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s13_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s13_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s13_slots_len}=  Get Length  ${s13_slots}

#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s13_slots_len}  

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
#         Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s13_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id13}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Suite Variable  ${apptid${a}}  ${apptid}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}
        

#     END

#     Log List   ${walkin_appt_ids}

#     sleep  01s
#     # sleep  10m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
#     # Set Suite Variable   ${walkin_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids)
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${started_appt_ids}=  Create List
#     # Set Suite Variable   ${started_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s13_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${apptid${a}}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#         Append To List   ${started_appt_ids}  ${apptid${a}}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s13_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#     END

#     sleep  01s
#     # sleep  10m
#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep   1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

    
#     ${started_appt_len}=  Get Length  ${started_appt_ids}
#     # Set Suite Variable   ${started_appt_len}
#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - $started_appt_len
#     # Set Suite Variable   ${arrived_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
#     # ${cancelled_appt_ids}=  Create List
#     # Set Suite Variable   ${cancelled_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s13_slots_len}  

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}
        
#         ${reason}=  Random Element  ${cancelReason}
#         ${msg}=   FakerLibrary.sentence
#         ${resp}=    Provider Cancel Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Append To List   ${cancelled_walkin_appt_ids}  ${apptid${a}}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s13_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

#     END

#     # sleep  10m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  1s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids)
#     # Set Suite Variable   ${cancelled_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    


# JD-TC-AccountLevelAnalytics-25
#     [Documentation]   change status from started to rejected and check STARTED_APPMT and CANCELLED_APPMT metrics

#     ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${pid}  ${resp.json()['id']}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id5}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id5}  ${DAY1}  ${s_id15}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  scheduleId=${sch_id5}
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{s15_slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s15_slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${s15_slots_len}=  Get Length  ${s15_slots}

#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s15_slots_len}  

#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
#         Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

#         ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s15_slots[${a}]}
#         ${apptfor}=   Create List  ${apptfor1}
            
#         ${cnote}=   FakerLibrary.word
#         ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id15}  ${sch_id5}  ${DAY1}  ${cnote}  ${apptfor}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
            
#         ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
#         Set Suite Variable  ${apptid${a}}  ${apptid}

#         Append To List   ${walkin_appt_ids}  ${apptid${a}}
        

#     END

#     Log List   ${walkin_appt_ids}

#     # sleep  01s
#     sleep  01s
    # sleep  01m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${walkin_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids)
#     # Set Suite Variable   ${walkin_appt_len}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids)
    
#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${started_appt_ids}=  Create List
#     # Set Suite Variable   ${started_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Verify Response   ${resp}  uid=${apptid${a}}  apptStatus=${apptStatus[2]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
            
#         ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#         Append To List   ${started_appt_ids}  ${apptid${a}}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         # Verify Response  ${resp}   uid=${online_prepay_appt_ids[${a}]}  apptStatus=${apptStatus[3]}
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

#     END

#     # sleep  01s
#     sleep  01s
    # sleep  01m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

    
#     ${started_appt_len}=  Get Length  ${started_appt_ids}
#     ${arrived_appt_len}=  Evaluate  len($walkin_appt_ids) + len($walkin_prepay_appt_ids) + len($walkin_vs_appt_ids) - len($cancelled_walkin_appt_ids) - len($rejected_walkin_appt_ids) - $started_appt_len

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['ARRIVED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['STARTED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
#     # ${cancelled_appt_ids}=  Create List
#     # Set Suite Variable   ${cancelled_appt_ids}
#     FOR   ${a}  IN RANGE   ${count}
    
#         Exit For Loop If    ${a}>=${s15_slots_len}  

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}
        
#         ${reason}=  Random Element  ${cancelReason}
#         ${msg}=   FakerLibrary.sentence
#         ${resp}=   Reject Appointment  ${apptid${a}}  ${reason}  ${msg}  ${DAY1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Append To List   ${rejected_walkin_appt_ids}  ${apptid${a}}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

#     END

#     FOR   ${a}  IN RANGE   ${count}

#         Exit For Loop If    ${a}>=${s15_slots_len}

#         ${resp}=  Get Appointment By Id   ${apptid${a}}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Log Many  ${resp.json()['apptStatus']}  ${resp.json()['appointmentMode']}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
#         Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

#     END

#     sleep  01s
    # sleep  01m

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${cancelled_appt_len}=  Evaluate  len($cancelled_online_appt_ids) + len($cancelled_online_prepay_appt_ids) + len($cancelled_walkin_appt_ids) + len($rejected_online_appt_ids) + len($rejected_walkin_appt_ids)

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['WALK_IN_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['STARTED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}

#     ${resp}=  Get Account Level Analytics  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${appointmentAnalyticsMetrics['CANCELLED_APPMT']}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_appt_len}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
