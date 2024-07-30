*** Settings ***
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
# Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
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
# &{tokenAnalyticsMetrics}   PHONE_TOKEN=1  WALK_IN_TOKEN=2  ONLINE_TOKEN=3  TELE_SERVICE_TOKEN=4
# ...  TOTAL_FOR_TOKEN=6  CHECKED_IN_TOKEN=7  ARRIVED_TOKEN=8  STARTED_TOKEN=9  CANCELLED_TOKEN=10  DONE_TOKEN=11
# ...  RESCHEDULED_TOKEN=12  TOTAL_ON_TOKEN=13  WEB_TOKENS=14  TOKENS_FOR_LICENSE_BILLING=20

# &{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24
# ...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
# ...  RESCHEDULED_APPMT=31  TOTAL_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34

# &{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0
@{empty_list}  
${count}       ${9}
${def_amt}     0.0



*** Test Cases ***
JD-TC-AccountLevelAnalyticsforWaitlist-1
    [Documentation]   take walkin checkins for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN

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


    # ------------ Sign up a provider with highest licence package and random domain and subdomain.
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Test Variable   ${licid}
    
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

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
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
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

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.content}
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
    
    # ------------- Get general details and settings of the provider and update all needed settings
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    # ${ser_durtn}=   Random Int   min=2   max=2
    # ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
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
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ------------------- Create service and queue  -------------------

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=30
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    Set Suite Variable  ${ser_names}

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id}

    comment  queue 1 for checkins    

    ${resp}=  Sample Queue  ${lid}   ${s_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id1}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ------------------- Add customers and take checkin  -------------------
    # comment  Add customers and take check-ins

    ${walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${walkin_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${walkin_waitlist_ids}  ${wid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    Log List   ${walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${empty_list}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 



JD-TC-AccountLevelAnalyticsforWaitlist-2
    [Documentation]   take prepayment checkin for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id1}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id1}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${prepay_walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${prepay_walkin_waitlist_ids}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${prepay_walkin_waitlist_ids}  ${wid${a}}

    END

    Log List   ${prepay_walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-3
    [Documentation]   take checkin for a virtual service for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
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

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id1}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id}  ${s_id1}  ${v_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${vs_walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${vs_walkin_waitlist_ids}
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${PUSERPH0}
        # ${resp}=  Add To Waitlist  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[0]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${vs_walkin_waitlist_ids}  ${wid${a}}

    END

    Log List   ${vs_walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) 
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-4
    [Documentation]   take online checkins for a provider and check account level analytics for ONLINE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE4}=    Set Variable  ${ser_names[3]}
    ${s_id4}=  Create Sample Service  ${SERVICE4}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id4}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}   ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id2}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${online_waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id2}  ${DAY}  ${s_id4}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${online_waitlist_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_waitlist_ids}
    Set Suite Variable   ${online_waitlist_ids}
    # change_system_time  1  30

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${online_token_len}=  Evaluate  len($online_waitlist_ids) 
    Set Suite Variable   ${online_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-5
    [Documentation]   take online checkins for a prepayment service for a provider and check account level analytics for ONLINE_TOKEN and CHECKED_IN_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  prepayment service for online check-ins 

    ${SERVICE5}=    Set Variable  ${ser_names[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id5}

    comment  queue 2 for checkins

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id2}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id4}  ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${online_prepay_wl_ids}=  Create List
    Set Suite Variable   ${online_prepay_wl_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id2}  ${DAY}  ${s_id5}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${online_prepay_wl_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_prepay_wl_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${online_token_len}=  Evaluate  len($online_waitlist_ids) 
    comment    online waitlist in prepaymentPending status is not considered in ONLINE_TOKEN.
    ${checkedin_token_len}=  Evaluate  len($online_waitlist_ids)

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable   ${online_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-AccountLevelAnalyticsforWaitlist-6
    [Documentation]   take online checkin for a virtual service for a provider and check account level analytics for ONLINE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  virtual service for online check-ins 

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

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id2}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id4}  ${s_id5}  ${v_s2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${vs_online_waitlist_ids}=  Create List
    Set Suite Variable   ${vs_online_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${vScallingmode}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${CUSERNAME${a}}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${q_id2}  ${DAY1}  ${v_s2}  ${cnote}  ${bool[0]}  ${vScallingmode}   0
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${vs_online_waitlist_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${vs_online_waitlist_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids)
    Set Suite Variable   ${online_token_len} 
    comment    online waitlist in prepaymentPending status is not considered in ONLINE_TOKEN.
    ${checkedin_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids)

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) + len($vs_online_waitlist_ids)
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-7
    [Documentation]   take phone-in checkins for a provider and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE7}=    Set Variable  ${ser_names[6]}
    ${s_id6}=  Create Sample Service  ${SERVICE7}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id6}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}   ${s_id6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id3}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id3}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${pro_phonein_waitlist_ids}=  Create List
    Set Suite Variable   ${pro_phonein_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist with mode  ${waitlistMode[2]}  ${cid${a}}  ${s_id6}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${pro_phonein_waitlist_ids}  ${wid${a}}

    END

    Log List   ${pro_phonein_waitlist_ids}

    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids)
    Set Suite Variable   ${phonein_token_len}

    sleep  01s
    # sleep  05m
    
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-8
    [Documentation]   take phone-in checkins for a prepayment service for a provider and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

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
    ${s_id7}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id7}

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id3}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id6}  ${s_id7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pro_phonein_prepay_waitlist_ids}=  Create List
    Set Suite Variable   ${pro_phonein_prepay_waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist with mode  ${waitlistMode[2]}  ${cid${a}}  ${s_id7}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${pro_phonein_prepay_waitlist_ids}  ${wid${a}}

    END

    Log List   ${pro_phonein_prepay_waitlist_ids}

    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) 
    Set Suite Variable   ${phonein_token_len}
    
    sleep  01s
    # sleep  05m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-AccountLevelAnalyticsforWaitlist-9
    [Documentation]   take phone-in checkin for a virtual service for a provider and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    comment  virtual service for phone-in check-ins 

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

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id3}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id6}  ${s_id7}  ${v_s3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${pro_vs_phonein_waitlist_ids}=  Create List
    Set Suite Variable   ${pro_vs_phonein_waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${PUSERPH0} 
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s3}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${pro_vs_phonein_waitlist_ids}  ${wid${a}}

    END

    Log List   ${pro_vs_phonein_waitlist_ids}

    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    Set Suite Variable   ${phonein_token_len}
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) + len($vs_online_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-AccountLevelAnalyticsforWaitlist-10
    [Documentation]   take token for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    comment  Services for tokens

    ${SERVICE10}=    Set Variable  ${ser_names[9]}
    ${s_id8}=  Create Sample Service  ${SERVICE10}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id8}

    comment  queue 2 for tokens

    ${resp}=  Sample Queue  ${lid}   ${s_id8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id4}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id4}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    comment  take token

    ${ser_durtn}=   Random Int   min=2   max=2
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id8}  ${q_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${walkin_waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${walkin_waitlist_ids}

    # ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $phonein_token_len - $online_token_len
    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-11
    [Documentation]   take prepayment token for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${SERVICE11}=    Set Variable  ${ser_names[10]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id9}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id9}

    comment  queue 2 for tokens

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Queue  ${q_id4}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id8}   ${s_id9}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id9}  ${q_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${prepay_walkin_waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${prepay_walkin_waitlist_ids}

    # ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $phonein_token_len - $online_token_len
    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}
    
    sleep  01s
    # sleep  07m
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-12
    [Documentation]   take token for a virtual service for a provider and check account level analytics for WALK_IN_TOKEN and ARRIVED_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
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

    comment  queue 2 for tokens

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id4}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id8}   ${s_id9}  ${v_s4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${PUSERPH0}
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s4}  ${q_id4}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[0]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        Append To List   ${vs_walkin_waitlist_ids}  ${token_wid${a}}

    END

    Log List   ${vs_walkin_waitlist_ids}

    # ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $phonein_token_len - $online_token_len
    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}
    
    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1} 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) + len($vs_online_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-13
    [Documentation]   make prepayments and check PRE_PAYMENT_COUNT and PRE_PAYMENT_TOTAL metrics.

    Log List   ${walkin_waitlist_ids}
    Log List   ${prepay_walkin_waitlist_ids}
    Log List   ${vs_walkin_waitlist_ids}
    Log List   ${online_waitlist_ids}
    Log List   ${online_prepay_wl_ids}
    Log List   ${vs_online_waitlist_ids}
    Log List   ${pro_phonein_waitlist_ids}
    Log List   ${pro_phonein_prepay_waitlist_ids}
    Log List   ${pro_vs_phonein_waitlist_ids}
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${prepaid_waitlist_ids}=  Create List
    Set Suite Variable   ${prepaid_waitlist_ids}
    

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable   ${cid}   ${resp.json()['id']}

        ${resp}=  Get consumer Waitlist By Id  ${online_prepay_wl_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[3]}
        Set Test Variable   ${pre_amt}   ${resp.json()['service']['minPrePaymentAmount']}
        Set Test Variable   ${s_id}   ${resp.json()['service']['id']}

        ${resp}=  Make payment Consumer Mock  ${pid}  ${pre_amt}  ${purpose[0]}  ${online_prepay_wl_ids[${a}]}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id  ${online_prepay_wl_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[0]}
        # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}
        # Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        Append To List   ${prepaid_waitlist_ids}  ${online_prepay_wl_ids[${a}]}

    END

    Log List   ${prepaid_waitlist_ids}

    # sleep  05s


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${j}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${j}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[0]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}

    END

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${tot_pre_amt}=  Evaluate  $pre_amt * $count
    
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
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${tot_pre_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    Log Many  ${walkin_token_len}  ${online_token_len}  ${phonein_token_len}
    # ${online_token_len}=  Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $walkin_token_len - $phonein_token_len
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids)
    Set Suite Variable   ${online_token_len}
    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    Set Suite Variable   ${phonein_token_len}
    Log Many  ${walkin_token_len}  ${online_token_len}  ${phonein_token_len}
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    Set Suite Variable   ${checkedin_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${prepaid_waitlist_len}=  Evaluate  len($prepaid_waitlist_ids)

    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['TOKEN_PRE_PAYMENT_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['TOKEN_PRE_PAYMENT_COUNT']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${count}
    Run Keyword And Continue On Failure  Should Be Equal  ${resp.json()['metricValues'][0]['value']}   ${prepaid_waitlist_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['TOKEN_PRE_PAYMENT_TOTAL']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['TOKEN_PRE_PAYMENT_TOTAL']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${tot_pre_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-AccountLevelAnalyticsforWaitlist-14
    [Documentation]   change status from checked-in to arrived and check ARRIVED_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${tot_prepaywl_len}=  Get Length  ${prepay_walkin_waitlist_ids}
    ${tot_wl_len}=  Get Length  ${walkin_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[0]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[0]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[1]}
            
        ${resp}=  Waitlist Action  ${waitlist_actions[0]}   ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]}

    END

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}   waitlistStatus=${wl_status[1]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[1]}

    END
    
    # sleep  10s
    # sleep  05m
    sleep  01s

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${walkin_token_len}  ${a}
    ${online_prepay_len}=  Get Length  ${online_prepay_wl_ids}
    Set Suite Variable   ${online_prepay_len}
    ${arrived_token_len}=  Evaluate  $walkin_token_len + $online_prepay_len
    Set Suite Variable   ${arrived_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len - $online_prepay_len
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids)
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-15
    [Documentation]   change status from arrived to started and check STARTED_TOKEN and ARRIVED_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${tot_prepaywl_len}=  Get Length  ${prepay_walkin_waitlist_ids}
    ${tot_wl_len}=  Get Length  ${walkin_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[1]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
            
        ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[2]}

    END

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[2]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}

    END
    
    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${arrived_token_len}  
    ${started_token_len}=  Get Length  ${online_prepay_wl_ids}
    Set Suite Variable   ${started_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['STARTED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['STARTED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${arrived_token_len}=  Evaluate  $arrived_token_len - $online_prepay_len
    Set Suite Variable   ${arrived_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-16
    [Documentation]   change status from started to done and check DONE_TOKEN and STARTED_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${tot_prepaywl_len}=  Get Length  ${prepay_walkin_waitlist_ids}
    ${tot_wl_len}=  Get Length  ${walkin_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}   200
        Verify Response  ${resp}   waitlistStatus=${wl_status[2]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
            
        ${resp}=  Waitlist Action  ${waitlist_actions[4]}   ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[5]}

    END

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[5]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}

    END

    # sleep  10s
    # sleep  05m
    sleep  01s

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${walkin_token_len}  ${a}

    ${started_token_len}=  Evaluate  $started_token_len - $online_prepay_len
    Set Suite Variable   ${started_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['STARTED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['STARTED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${started_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${done_token_len}=  Get Length  ${online_prepay_wl_ids}
    Set Suite Variable   ${done_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['DONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['DONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${done_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-17
    [Documentation]   cancel a checkin in checked-in status and check CHECKED_IN_TOKEN and CANCELLED_TOKEN

    Log List   ${walkin_waitlist_ids}
    Log List   ${prepay_walkin_waitlist_ids}
    Log List   ${vs_walkin_waitlist_ids}
    Log List   ${online_waitlist_ids}
    Log List   ${online_prepay_wl_ids}
    Log List   ${vs_online_waitlist_ids}
    Log List   ${pro_phonein_waitlist_ids}
    Log List   ${pro_phonein_prepay_waitlist_ids}
    Log List   ${pro_vs_phonein_waitlist_ids}  

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${tot_prepaywl_len}=  Get Length  ${prepay_walkin_waitlist_ids}
    # ${tot_wl_len}=  Get Length  ${walkin_waitlist_ids}

    # FOR   ${i}  IN RANGE   ${count}

    #     ${resp}=  Get Waitlist By Id  ${walkin_waitlist_ids[${i}]}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
          
    #     Continue For Loop If   '${resp.json()['waitlistStatus']}' != '${wl_status[0]}'
    #     # ${resp1}=  Run Keyword If  '${resp.json()['waitlistStatus']}' == '${wl_status[0]}'   Get Waitlist By Id  ${walkin_waitlist_ids[${i+${count}}]}
    #     # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    #     # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    #     IF  '${resp.json()['waitlistStatus']}' == '${wl_status[0]}'
    #         ${resp1}=  Get Waitlist By Id  ${walkin_waitlist_ids[${i+${count}}]}
    #         Log  ${resp1.content}
    #         Should Be Equal As Strings  ${resp1.status_code}  200
    #     END
        
    #     Log Many  ${resp1.json()['waitlistStatus']}  ${resp1.json()['waitlistMode']}
    #     Exit For Loop If  '${resp1.json()['waitlistStatus']}' == '${wl_status[0]}'
    #     Exit For Loop If  '${resp.json()['waitlistStatus']}' == '${wl_status[0]}'
        

    # END

    ${cancelled_wl_ids}=  Create List
    Set Suite Variable   ${cancelled_wl_ids}
    # FOR   ${a}  IN RANGE   ${i}  ${i+${count}}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[0]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
            
        ${desc}=   FakerLibrary.sentence
        ${resp}=  Waitlist Action Cancel  ${online_waitlist_ids[${a}]}  ${waitlist_cancl_reasn[7]}   ${desc}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[4]}

        Append To List   ${cancelled_wl_ids}  ${online_waitlist_ids[${a}]}

    END

    # FOR   ${a}  IN RANGE   ${i}  ${i+${count}}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${online_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[4]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        

    END

    Log List   ${cancelled_wl_ids}
    # Set Suite Variable   ${cancelled_wl_ids}
    
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    
    Log Many  ${checkedin_token_len}  ${a} 
    ${cancelled_token_len}=  Get Length  ${cancelled_wl_ids}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CANCELLED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${checkedin_token_len}=  Evaluate  $checkedin_token_len - $cancelled_token_len
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids)
    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len - $cancelled_token_len - len($online_prepay_wl_ids)
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-18
    [Documentation]   cancel a checkin in arrived status and check ARRIVED_TOKEN and CANCELLED_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${tot_prepaywl_len}=  Get Length  ${prepay_walkin_waitlist_ids}
    ${tot_wl_len}=  Get Length  ${walkin_waitlist_ids}

    # FOR   ${i}  IN RANGE   ${tot_wl_len}

    #     ${resp}=  Get Waitlist By Id  ${walkin_waitlist_ids[${i}]}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
          
    #     Continue For Loop If   '${resp.json()['waitlistStatus']}' != '${wl_status[1]}'
    #     ${resp1}=  Run Keyword If  '${resp.json()['waitlistStatus']}' == '${wl_status[1]}'   Get Waitlist By Id  ${walkin_waitlist_ids[${i+${count}}]}
    #     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    #     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
        
    #     Log Many  ${resp1.json()['waitlistStatus']}  ${resp1.json()['waitlistMode']}
    #     Exit For Loop If  '${resp1.json()['waitlistStatus']}' == '${wl_status[1]}'
    #     Exit For Loop If  '${resp.json()['waitlistStatus']}' == '${wl_status[1]}'
        

    # END

    
    # FOR   ${a}  IN RANGE   ${i}  ${i+${count}}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${walkin_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[1]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        
        ${desc}=   FakerLibrary.sentence
        ${resp}=  Waitlist Action Cancel  ${walkin_waitlist_ids[${a}]}  ${waitlist_cancl_reasn[7]}   ${desc}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${walkin_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['waitlistStatus']}   ${wl_status[4]}

        Append To List   ${cancelled_wl_ids}  ${walkin_waitlist_ids[${a}]}

    END

    # FOR   ${a}  IN RANGE   ${i}  ${i+${count}}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waitlist By Id  ${walkin_waitlist_ids[${a}]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   waitlistStatus=${wl_status[4]}
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}

    END
    
    Log List   ${cancelled_wl_ids}
    Set Suite Variable   ${cancelled_wl_ids}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${walkin_token_len}  ${a} 
    ${cancelled_token_len}=  Get Length  ${cancelled_wl_ids}
    Set Suite Variable   ${cancelled_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CANCELLED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${cancelled_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${walkin_token_len}=  Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $cancelled_token_len/2
    ${walkin_token_len}=  Convert To Integer  ${walkin_token_len}
    Set Suite Variable   ${walkin_token_len}
    ${arrived_token_len}=  Evaluate  $walkin_token_len 
    # ${arrived_token_len}=  Convert To Integer  ${arrived_token_len}
    Set Suite Variable   ${arrived_token_len}
    
    # ${arrived_token_len}=  Evaluate  $walkin_token_len - $cancelled_token_len/2
    # ${arrived_token_len}=  Convert To Integer  ${arrived_token_len}
    # Set Suite Variable   ${arrived_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-19
    [Documentation]   Reschedule a checkin in checked-in status and check CHECKED_IN_TOKEN and RESCHEDULED_TOKEN

    Log List   ${walkin_waitlist_ids}
    Log List   ${prepay_walkin_waitlist_ids}
    Log List   ${vs_walkin_waitlist_ids}
    Log List   ${online_waitlist_ids}
    Log List   ${online_prepay_wl_ids}
    Log List   ${vs_online_waitlist_ids}
    Log List   ${pro_phonein_waitlist_ids}
    Log List   ${pro_phonein_prepay_waitlist_ids}
    Log List   ${pro_vs_phonein_waitlist_ids}


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${SERVICE13}=    Set Variable  ${ser_names[12]}
    ${s_id10}=  Create Sample Service  ${SERVICE13}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id10}

    comment  queue 1 for checkins    

    ${resp}=  Sample Queue  ${lid}   ${s_id10} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id5}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id5}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id10}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${walkin_waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id5}  ${DAY}  ${s_id10}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${online_waitlist_ids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_waitlist_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    # sleep  10s
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s
    Log Many  ${online_token_len}  ${checkedin_token_len}  ${cancelled_wl_ids}
    # ${online_token_len}=  Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - $walkin_token_len - $phonein_token_len    - $cancelled_token_len/2
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids) 
    ${online_token_len}=  Convert To Integer  ${online_token_len}
    Set Suite Variable   ${online_token_len}
    comment  changed status of online_prepay_wl_ids upto done in cases 13-16 and cancelled online_waitlist_ids in case 17
    # ${checkedin_token_len}=  Evaluate  $checkedin_token_len + $count
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len - len($online_prepay_wl_ids)
    Set Suite Variable   ${checkedin_token_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_wl_ids}=  Create List
    ${rescheduled_online_wl_ids}=  Create List


    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${DAY3}=  db.add_timezone_date  ${tz}  4  
        ${resp}=  Reschedule Waitlist  ${pid}  ${cwid${a}}  ${DAY3}  ${q_id5}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_wl_ids}  ${cwid${a}}
        Append To List   ${rescheduled_online_wl_ids}  ${cwid${a}}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY3}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${rescheduled_online_wl_ids}
    Set Suite Variable   ${rescheduled_online_wl_ids}

    Log List   ${rescheduled_wl_ids}
    Set Suite Variable   ${rescheduled_wl_ids}

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

    Log Many  ${checkedin_token_len}

    ${reschedule_len}=  Get Length  ${rescheduled_wl_ids}
    ${reschedule_online_len}=  Get Length  ${rescheduled_online_wl_ids}
    Set Suite Variable   ${reschedule_online_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${checkedin_token_len}=  Evaluate  $checkedin_token_len - $reschedule_len
    ${checkedin_token_len}=  Convert To Integer  ${checkedin_token_len}
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY3}  ${DAY3}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY3}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY3}  ${DAY3}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_online_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY3}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-20

    [Documentation]   Reschedule a checkin in arrived status and check ARRIVED_TOKEN and RESCHEDULED_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${SERVICE14}=    Set Variable  ${ser_names[13]}
    ${s_id11}=  Create Sample Service  ${SERVICE14}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id11}

    comment  queue 1 for checkins    

    ${resp}=  Get Queue ById  ${q_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Queue  ${q_id5}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id10}  ${s_id11}

    ${resp}=  Get Queue ById  ${q_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id11}  ${q_id5}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${walkin_waitlist_ids}  ${wid${a}}

    END

    Log List   ${walkin_waitlist_ids}

    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${walkin_token_len}=  Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) 
    ${walkin_token_len}=  Convert To Integer  ${walkin_token_len}
    Set Suite Variable   ${walkin_token_len}
    ${arrived_token_len}=  Evaluate  $walkin_token_len - $cancelled_token_len/2
    ${arrived_token_len}=  Convert To Integer  ${arrived_token_len}
    Set Suite Variable   ${arrived_token_len}
    # ${arrived_token_len}=  Evaluate  $arrived_token_len + $count
    # Set Suite Variable   ${arrived_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${rescheduled_walkin_wl_ids}=  Create List

    FOR   ${a}  IN RANGE   ${count}

        ${DAY3}=  db.add_timezone_date  ${tz}  4  
        ${resp}=  Reschedule Consumer Checkin   ${wid${a}}  ${DAY3}  ${q_id5}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${rescheduled_wl_ids}  ${wid${a}}
        Append To List   ${rescheduled_walkin_wl_ids}  ${wid${a}}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY3}     

    END
    
    Log List   ${rescheduled_walkin_wl_ids}
    Log List   ${rescheduled_wl_ids}
    Set Suite Variable   ${rescheduled_wl_ids}

    sleep  01s
    # sleep  07m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${reschedule_walkin_len}=  Get Length  ${rescheduled_walkin_wl_ids}
    ${reschedule_len}=  Get Length  ${rescheduled_wl_ids}
    Set Suite Variable   ${reschedule_len}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${arrived_token_len}=  Evaluate  $arrived_token_len - $count
    ${arrived_token_len}=  Evaluate  $arrived_token_len - $reschedule_len/2
    ${arrived_token_len}=  Convert To Integer  ${arrived_token_len}
    Set Suite Variable   ${arrived_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${arrived_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY3}  ${DAY3}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY3}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY3}  ${DAY3}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_walkin_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY3}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY3}  ${DAY3}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${reschedule_online_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY3}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-21

    [Documentation]   check TOTAL_ON_TOKEN, TOTAL_FOR_TOKEN, WEB_TOKENS, TOKENS_FOR_LICENSE_BILLING and BRAND_NEW_TOKENS

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    Log Many  ${walkin_waitlist_ids}  ${prepay_walkin_waitlist_ids}  ${vs_walkin_waitlist_ids}  ${cancelled_wl_ids}  ${rescheduled_wl_ids}
    # ${total_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) - len($cancelled_wl_ids) - len($rescheduled_wl_ids)
    ${total_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids) + len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    ${today_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids) + len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) - len($rescheduled_wl_ids)
    ${active_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids) + len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) - len($cancelled_wl_ids)
    ${today_active_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($vs_walkin_waitlist_ids) + len($online_waitlist_ids) + len($online_prepay_wl_ids) + len($vs_online_waitlist_ids) + len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) - len($cancelled_wl_ids) - len($rescheduled_wl_ids)

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${total_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${active_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WEB_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WEB_TOKENS']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${today_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    
    ${lic_bill_token_len}=   Evaluate  $today_active_token_len - $no_of_cust
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${lic_bill_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) + len($vs_online_waitlist_ids) + len($pro_vs_phonein_waitlist_ids)
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-AccountLevelAnalyticsforWaitlist-22

    [Documentation]   Make bill payment and check BILL_PAYMENT_COUNT and BILL_PAYMENT_TOTAL metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist By Id  ${online_prepay_wl_ids[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${service_id}   ${resp.json()['service']['id']}

    ${resp}=   Get Service By Id  ${service_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['totalAmount']}
    Set Test Variable   ${pre_amt}   ${resp.json()['minPrePaymentAmount']}

    ${bal_amt}=  Evaluate  $tot_amt - $pre_amt

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable   ${cid}   ${resp.json()['id']}

        ${resp}=  Get consumer Waitlist By Id  ${online_prepay_wl_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}   
        
        ${resp}=  Get Bill By consumer  ${online_prepay_wl_ids[${a}]}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  uuid=${online_prepay_wl_ids[${a}]}  
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['netRate']}   ${tot_amt} 
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['amountDue']}   ${bal_amt}

        # ${resp}=  Make payment Consumer Mock  ${bal_amt}  ${bool[1]}  ${online_prepay_wl_ids[${a}]}  ${pid}  ${purpose[1]}  ${cid}
        ${resp}=  Make payment Consumer Mock  ${pid}  ${bal_amt}  ${purpose[1]}  ${online_prepay_wl_ids[${a}]}  ${service_id}  ${bool[0]}   ${bool[1]}  ${cid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Payment Details  account-eq=${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[1]['amount']}   ${pre_amt}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[1]['accountId']}   ${pid}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${bal_amt}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}

        # ${resp}=  Get consumer Waitlist By Id  ${online_prepay_wl_ids[${a}]}  ${pid}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        # Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get consumer Waitlist By Id  ${online_prepay_wl_ids[${a}]}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Log Many  ${resp.json()['waitlistStatus']}  ${resp.json()['waitlistMode']}
        Verify Response  ${resp}  paymentStatus=${paymentStatus[2]}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END
    
    ${billed_wl_len}=  Get Length  ${online_prepay_wl_ids}
    
    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${billed_wl_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${tot_bill_paid_amt}=  Evaluate  $bal_amt * $count
    
    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${self}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${tot_bill_paid_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['TOKEN_BILL_PAYMENT_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['TOKEN_BILL_PAYMENT_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${billed_wl_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
    
    ${resp}=  Get Account Level Analytics  ${paymentAnalyticsMetrics['TOKEN_BILL_PAYMENT_TOTAL']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${paymentAnalyticsMetrics['TOKEN_BILL_PAYMENT_TOTAL']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${self}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${tot_bill_paid_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalyticsforWaitlist-23

    [Documentation]   take phone-in checkins for a provider from consumer side and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE15}=    Set Variable  ${ser_names[14]}
    ${s_id12}=  Create Sample Service  ${SERVICE15}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id12}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}   ${s_id12} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id6}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id6}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${con_phonein_waitlist_ids}=  Create List
    Set Suite Variable   ${con_phonein_waitlist_ids}
    
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers with mode  ${waitlistMode[2]}  ${pid}  ${q_id6}  ${DAY1}  ${s_id12}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${con_phonein_waitlist_ids}  ${cwid${a}}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${con_phonein_waitlist_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log Many  ${online_token_len}  ${walkin_token_len}  ${phonein_token_len}
    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) + len($con_phonein_waitlist_ids) 
    Set Suite Variable   ${phonein_token_len}

    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    Log Many  ${checkedin_token_len}  ${count}  ${online_token_len}  ${phonein_token_len}  ${reschedule_len}  ${cancelled_token_len}
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids) - $cancelled_token_len/2 - $reschedule_len/2
    ${online_token_len}=  Convert To Integer  ${online_token_len}
    Set Suite Variable   ${online_token_len}
    
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    # ${checkedin_token_len}=  Convert To Integer  ${checkedin_token_len}
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalyticsforWaitlist-24
    [Documentation]   take phone-in checkins from consumer side for a prepayment service for a provider and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${SERVICE16}=    Set Variable  ${ser_names[15]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id13}=  Create Sample Service with Prepayment   ${SERVICE16}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id13}

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id6}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id12}  ${s_id13}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${con_phonein_prepay_waitlist_ids}=  Create List
    Set Suite Variable   ${con_phonein_prepay_waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers with mode  ${waitlistMode[2]}  ${pid}  ${q_id6}  ${DAY1}  ${s_id13}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${con_phonein_prepay_waitlist_ids}  ${cwid${a}}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${con_phonein_prepay_waitlist_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) + len($con_phonein_waitlist_ids) + len($con_phonein_prepay_waitlist_ids)
    Set Suite Variable   ${phonein_token_len}
    
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END


    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    Log Many  ${checkedin_token_len}  ${count}  ${online_token_len}  ${phonein_token_len}  ${reschedule_len}  ${cancelled_token_len}
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids) - $cancelled_token_len/2 - $reschedule_len/2
    ${online_token_len}=  Convert To Integer  ${online_token_len}
    Set Suite Variable   ${online_token_len}
    
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    # ${checkedin_token_len}=  Convert To Integer  ${checkedin_token_len}
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalyticsforWaitlist-25
    [Documentation]   take phone-in checkin from consumer side for a virtual service for a provider and check account level analytics for PHONE_TOKEN and CHECKED_IN_TOKEN metrics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    comment  virtual service for phone-in check-ins 

    Set Test Variable  ${callingMode1}     ${CallingModes[1]}
    Set Test Variable  ${ModeId1}          ${PUSERPH0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VScallingMode1}

    ${Total1}=   Random Int   min=100   max=500
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE17}=    Set Variable  ${ser_names[16]}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE17}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s5}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ${time_now}=  db.get_time_by_timezone   ${tz}
    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${resp}=  Update Queue  ${q_id6}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id12}  ${s_id13}  ${v_s5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${con_vs_phonein_waitlist_ids}=  Create List
    Set Suite Variable   ${con_vs_phonein_waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${vScallingmode}=  Create Dictionary   ${CallingModes[1]}=${countryCodes[0]}${CUSERNAME${a}}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Virtual Service Checkin with Mode  ${waitlistMode[2]}  ${pid}  ${q_id6}  ${DAY1}  ${v_s5}  ${cnote}  ${bool[0]}  ${vScallingmode}   0
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${con_vs_phonein_waitlist_ids}  ${cwid${a}}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${con_vs_phonein_waitlist_ids}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${phonein_token_len}=  Evaluate  len($pro_phonein_waitlist_ids) + len($pro_phonein_prepay_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) + len($con_phonein_waitlist_ids) + len($con_phonein_prepay_waitlist_ids) + len($con_vs_phonein_waitlist_ids)
    Set Suite Variable   ${phonein_token_len}
    
    sleep  01s
    # sleep  10m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    # ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    # Set Suite Variable   ${checkedin_token_len}
    Log Many  ${checkedin_token_len}  ${count}
    ${online_token_len}=  Evaluate  len($online_waitlist_ids) + len($vs_online_waitlist_ids) - $cancelled_token_len/2 - $reschedule_len/2
    ${online_token_len}=  Convert To Integer  ${online_token_len}
    Set Suite Variable   ${online_token_len}
    
    ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    # ${checkedin_token_len}=  Convert To Integer  ${checkedin_token_len}
    Set Suite Variable   ${checkedin_token_len}
    
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${VS_token_len}=   Evaluate  len($vs_walkin_waitlist_ids) + len($vs_online_waitlist_ids) + len($pro_vs_phonein_waitlist_ids) + len($con_vs_phonein_waitlist_ids)
    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${VS_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ONLINE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AccountLevelAnalyticsforWaitlist-26
    [Documentation]   check account level analytics for multiple tokens with CHECKED_IN_TOKEN and ARRIVED_TOKEN metrics

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

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['PHONE_TOKEN']},${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['PHONE_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['value']}   ${checkedin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][1]['dateFor']}   ${DAY1}

    # ${checkedin_token_len}=  Evaluate  $online_token_len + $phonein_token_len
    # Set Suite Variable   ${checkedin_token_len}
    
    # ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['TOKENS_FOR_LICENSE_BILLING']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['BRAND_NEW_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comments ***

JD-TC-AccountLevelAnalyticsforWaitlist-27
    [Documentation]   take a future checkin and check account level analytics for CHECKED_IN_TOKEN and ONLINE_TOKEN metrics for future date.


JD-TC-AccountLevelAnalyticsforWaitlist-UH1
    [Documentation]   take checkin for some other provider and check analytics count.


JD-TC-AccountLevelAnalyticsforWaitlist-UH2
    [Documentation]   take checkin for some other provider and check analytics count.




