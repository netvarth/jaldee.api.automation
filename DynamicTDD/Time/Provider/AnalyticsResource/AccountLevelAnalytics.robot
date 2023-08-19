*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
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
&{tokenAnalyticsMetrics}   PHONE_TOKEN=1  WALK_IN_TOKEN=2  ONLINE_TOKEN=3  TELE_SERVICE_TOKEN=4
...  TOTAL_FOR_TOKEN=6  CHECKED_IN_TOKEN=7  ARRIVED_TOKEN=8  STARTED_TOKEN=9  CANCELLED_TOKEN=10  DONE_TOKEN=11
...  RESCHEDULED_TOKEN=12  TOTAL_ON_TOKEN=13  WEB_TOKENS=14  TOKENS_FOR_BILLING=20

&{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24
...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
...  RESCHEDULED_APPMT=31  TOTAL_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34

&{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0


*** Test Cases ***
JD-TC-AccountLevelAnalytics-1
    [Documentation]   take checkins, tokens and appointments for a provider and check account level analytics for walkin tokens and appointments

    FOR   ${a}  IN RANGE   9
            
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

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${DAY1}=  get_date
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
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  45
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${ser_durtn}=   Random Int   min=2   max=2
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
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

    # ${PUSERPH_id0}=  Evaluate  ${PUSERNAME}+10101
    # ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    # Set Suite Variable   ${ZOOM_Pid0}

    # Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    # Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    # Set Test Variable  ${ModeStatus1}      ACTIVE
    # ${Description1}=    FakerLibrary.sentence
    # ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    # ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=20
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    Set Suite Variable  ${ser_names}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}

    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}
    Set Suite Variable  ${s_id1}
    
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

    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names[3]}
    ${s_id2}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id2}

    ${SERVICE5}=    Set Variable  ${ser_names[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id3}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}
    Set Suite Variable  ${s_id3}

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

    comment  Services for appointments

    ${SERVICE7}=    Set Variable  ${ser_names[6]}
    ${s_id4}=  Create Sample Service  ${SERVICE7}
    Set Suite Variable  ${s_id4}

    ${SERVICE8}=    Set Variable  ${ser_names[7]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre}  ${servicecharge}
    Set Suite Variable  ${s_id5}

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

    comment  queue 1 for checkins

    ${resp}=  Sample Queue   ${lid}   ${s_id}   ${s_id1}   ${v_s1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id1}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   100  ${lid}  ${s_id}  ${s_id1}  ${v_s1}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    comment  queue 2 for tokens

    ${resp}=  Sample Queue   ${lid}   ${s_id2}   ${s_id3}   ${v_s2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id2}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   100  ${lid}  ${s_id2}   ${s_id3}   ${v_s2}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id4}   ${s_id5}   ${v_s3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}   ${s_id5}   ${v_s3}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment  Add customers
    # ${customers}=  Create List
    FOR   ${a}  IN RANGE   9
            
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

    comment  take check-ins

    ${waitlist_ids}=  Create List
    Set Suite Variable   ${waitlist_ids}
    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${waitlist_ids}  ${wid${a}}

    END

    Log List   ${waitlist_ids}

    ${prepay_waitlist_ids}=  Create List
    Set Suite Variable   ${prepay_waitlist_ids}
    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${prepay_waitlist_ids}  ${wid${a}}

    END

    Log List   ${prepay_waitlist_ids}

    ${vs_waitlist_ids}=  Create List
    Set Suite Variable   ${vs_waitlist_ids}
    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${PUSERPH0}
        # ${resp}=  Add To Waitlist  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${vs_waitlist_ids}  ${wid${a}}

    END

    Log List   ${vs_waitlist_ids}
    
    comment  take token

    ${ser_durtn}=   Random Int   min=2   max=2
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id2}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${waitlist_ids}

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${prepay_waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${prepay_waitlist_ids}

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${PUSERPH0}
        # ${resp}=  Add To Waitlist  ${cid${a}}  ${v_s2}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s2}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${vs_waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${vs_waitlist_ids}

    comment  take appointment

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s4_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s4_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s4_num_slots}=  Get Length  ${s4_slots}

    ${appt_ids}=  Create List
    Set Suite Variable   ${appt_ids}
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s4_num_slots}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s4_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id4}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${a}}

    END

    Log List   ${appt_ids}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s5_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s5_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s5_num_slots}=  Get Length  ${s5_slots}

    
    ${prepay_appt_ids}=  Create List
    Set Suite Variable   ${prepay_appt_ids}
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s5_num_slots}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s5_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id5}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid}
        # ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        # Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${prepay_appt_ids}  ${apptid${a}}

    END

    Log List   ${prepay_appt_ids}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${v_s3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{vs3_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${vs3_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${vs3_num_slots}=  Get Length  ${vs3_slots}
    
    
    ${vs_appt_ids}=  Create List
    Set Suite Variable   ${vs_appt_ids}
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${vs3_num_slots}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${vs3_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        # ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${v_s3}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        ${resp}=  Take Virtual Service Appointment For Consumer  ${cid${a}}  ${v_s3}  ${sch_id}  ${DAY1}  ${cnote}  ${CallingModes[1]}  ${countryCodes[0]}${PUSERPH0}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${vs_appt_ids}  ${apptid${a}}

    END

    Log List   ${vs_appt_ids}

    ${walkin_token_len}=   Evaluate  len($waitlist_ids) + len($prepay_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    sleep  01s

    # # ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=2021-09-23  frequency=DAILY
    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # sleep  03s

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    change_system_time  1  30

    ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # # ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # # Log  ${resp.content}
    # # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Flush Analytics Data to DB

    # # sleep  05s

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  



    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${checkedin_token_len}=  Evaluate  len($vs_waitlist_ids)
    Set Suite Variable   ${checkedin_token_len}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${walkin_appt_len}=  Evaluate  len($appt_ids) + len($prepay_appt_ids)
    Set Suite Variable   ${walkin_appt_len}
    
    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Set Variable  ${{ len(@{vs_appt_ids}) }}
    Set Suite Variable   ${confirmed_appt_len}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-2
    [Documentation]   take online checkins and appointments for a provider and check account level analytics for online tokens and appointments
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE10}=    Set Variable  ${ser_names[9]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Suite Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[10]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id7}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}
    Set Suite Variable  ${s_id7}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue   ${lid}   ${s_id6}   ${s_id7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id3}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time
    ${resp}=  Update Queue  ${q_id3}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id6}  ${s_id7}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id6}   ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_ids}

    # ${waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${prepay_waitlist_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${prepay_waitlist_ids}


    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s6_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s6_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id6}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${appt_ids}

    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s7_num_slots}  

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
        
        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${s7_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${pid}  ${s_id7}  ${sch_id1}  ${DAY}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
        Set Suite Variable  ${apptid${a}}  ${apptid1}

        Append To List   ${prepay_appt_ids}  ${apptid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${prepay_appt_ids}

    # change_system_time  1  30

    ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${online_token_len}=  Evaluate  len($waitlist_ids) + len($prepay_waitlist_ids) - $walkin_token_len
    Set Suite Variable   ${online_token_len}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    sleep  01s
    
    ${resp}=  Flush Analytics Data to DB

    # sleep  05s

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${online_token_len}=  Set Variable  ${{ len('${waitlist_ids}') + len('${prepay_waitlist_ids}') - $walkin_token_len }}
    ${checkedin_token_len}=  Evaluate  $online_token_len + $checkedin_token_len
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${online_appt_len}=  Evaluate   len($appt_ids) + len($prepay_appt_ids) - $walkin_appt_len
    
    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['ONLINE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${online_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['WALK_IN_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${walkin_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${confirmed_appt_len}=  Evaluate  $online_appt_len + $confirmed_appt_len
    Set Suite Variable   ${confirmed_appt_len}
    
    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${confirmed_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-AccountLevelAnalytics-3
    [Documentation]   take phone-in checkins and appointments for a provider and check account level analytics for online tokens and appointments
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE12}=    Set Variable  ${ser_names[11]}
    ${s_id8}=  Create Sample Service  ${SERVICE12}
    Set Suite Variable  ${s_id8}

    ${SERVICE13}=    Set Variable  ${ser_names[12]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id9}=  Create Sample Service with Prepayment   ${SERVICE13}  ${min_pre}  ${servicecharge}
    Set Suite Variable  ${s_id9}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue   ${lid}   ${s_id8}   ${s_id9} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time
    ${resp}=  Update Queue  ${q_id4}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id8}  ${s_id9}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid}   ${s_id8}   ${s_id9}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id2}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id8}   ${s_id9}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id2}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s8_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s8_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s8_num_slots}=  Get Length  ${s8_slots}


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id9}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id2}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s9_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s9_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s9_num_slots}=  Get Length  ${s9_slots}

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   9

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist with mode  ${waitlistMode[2]}  ${cid${a}}  ${s_id8}  ${q_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${waitlist_ids}  ${wid${a}}

    END

    Log List   ${waitlist_ids}

    # ${waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist with mode  ${waitlistMode[2]}  ${cid${a}}  ${s_id9}  ${q_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${prepay_waitlist_ids}  ${wid${a}}

    END

    Log List   ${prepay_waitlist_ids}


    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9

        Exit For Loop If    ${a}>=${s8_num_slots} 

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']} 

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s8_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid${a}}  ${s_id8}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${a}}


    END

    Log List   ${appt_ids}

    # ${appt_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        Exit For Loop If    ${a}>=${s9_num_slots}  

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s9_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment with Appointment Mode  ${appointmentMode[1]}  ${cid${a}}  ${s_id9}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        ${apptid}=  Get From Dictionary  ${resp.json()}  ${fname}
        # Set Suite Variable  ${apptid${a}}  ${apptid[0]}
        Set Suite Variable  ${apptid${a}}  ${apptid}

        Append To List   ${prepay_appt_ids}  ${apptid${a}}


    END

    Log List   ${prepay_appt_ids}

    # change_system_time  1  30

    # ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${phonein_token_len}=  Evaluate  len($waitlist_ids) + len($prepay_waitlist_ids) - $walkin_token_len - $online_token_len + len($vs_waitlist_ids)
    
    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    sleep  01s

    ${resp}=  Flush Analytics Data to DB

    # sleep  05s

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['PHONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${phonein_appt_len}=  Evaluate  len($appt_ids) + len($prepay_appt_ids) - $walkin_appt_len - $online_appt_len + len($vs_appt_ids)

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${appointmentAnalyticsMetrics['PHONE_APPMT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['counter']}   ${phonein_appt_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['ARRIVED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${appointmentAnalyticsMetrics['CONFIRMED_APPMT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalytics-4
    [Documentation]   make prepayments and check PRE_PAYMENT_COUNT and PRE_PAYMENT_TOTAL metrics.

    Log List   ${waitlist_ids}
    Log List   ${prepay_waitlist_ids}
    Log List   ${vs_waitlist_ids}
    Log List   ${appt_ids}
    Log List   ${prepay_appt_ids}
    Log List   ${vs_appt_ids}


    FOR   ${a}  IN RANGE   9
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        # Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}
        ${cid1}=  get_id  ${CUSERNAME${a}}

        ${resp}=  Get consumer Waitlist By Id  ${prepay_waitlist_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   #waitlistStatus=${wl_status[3]}
        Set Test Variable   ${pre_amt}   ${resp.json()['service']['minPrePaymentAmount']}

        ${resp}=  Make payment Consumer Mock  ${pre_amt}  ${bool[1]}  ${prepay_waitlist_ids[${a}]}  ${pid}  ${purpose[0]}  ${cid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id  ${prepay_waitlist_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    sleep  01s

    ${resp}=  Flush Analytics Data to DB

    ${resp}=   Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




