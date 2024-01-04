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
&{tokenAnalyticsMetrics}   PHONE_TOKEN=1  WALK_IN_TOKEN=2  ONLINE_TOKEN=3  TELE_SERVICE_TOKEN=4
...  TOTAL_FOR_TOKEN=6  CHECKED_IN_TOKEN=7  ARRIVED_TOKEN=8  STARTED_TOKEN=9  CANCELLED_TOKEN=10  DONE_TOKEN=11
...  RESCHEDULED_TOKEN=12  TOTAL_ON_TOKEN=13  WEB_TOKENS=14  TOKENS_FOR_LICENSE_BILLING=20

&{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

&{orderAnalyticsMetrics}  PHONE_IN_ORDER=40  WALK_IN_ORDER=41  ONLINE_ORDER=42  TOTAL_ORDER=43
...  RECEIVED_ORDER=56  ACKNOWLEDGED_ORDER=57  CONFIRMED_ORDER=58  PREPARING_ORDER=59  PACKING_ORDER=60
...  READY_FOR_PICKUP_ORDER=61  READY_FOR_SHIPMENT_ORDER=62  READY_FOR_DELIVERY_ORDER=63  COMPLETED_ORDER=63
...  IN_TRANSIT_ORDER=64  SHIPPED_ORDER=65  PAYMENT_REQUIRED_ORDER=66  CANCEL_ORDER=67  IOS_ORDER=68
...  ANDROID_ORDER=69  JALDEE_LINK_ORDER=70  QR_CODE_ORDER=71  TOTAL_ON_ORDER=72  WEB_ORDER=73  ORDERS_FOR_BILLING=74

&{donationAnalyticsMetrics}  DONATION_COUNT=48  DONATION_TOTAL=49  

&{consumerAnalyticsMetrics}   WEB_NEW_CONSUMER_COUNT=50  TELEGRAM_NEW_CONSUMER_COUNT=51  IOS_NEW_CONSUMER_COUNT=52  
... 	NEW_CONSUMER_TOTAL=54  TOTAL_BRAND_NEW_TRANSACTIONS=55  ANDROID_NEW_CONSUMER_COUNT=53



${digits}       0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}    0

*** Test Cases ***

JD-TC-SubSubdomainLevelAnalytics-1
    [Documentation]   take checkins for normal service for a provider and check subdomain level analytics

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
    Set Suite Variable  ${subdomain_id}  ${resp2.json()['serviceSubSector']['id']}
    
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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

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

    comment  take check-ins

    ${walkin_ids}=  Create List
    Set Suite Variable   ${walkin_ids}
    FOR   ${a}  IN RANGE   10
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_ids}  ${wid${a}}

    END
    ${walkin_token_len}=   Evaluate  len($walkin_ids)
    Set Suite Variable   ${walkin_token_len}
    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    domainId=${domain_id}   subdomainId=${subdomain_id}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-SubdomainLevelAnalytics-2
    [Documentation]   take checkins for teleservice for a provider and check subdomain level analytics

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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}   ${v_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}


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

    comment  take check-ins

    ${walkin_vertual_ids}=  Create List
    Set Suite Variable   ${walkin_vertual_ids}

    FOR   ${a}  IN RANGE   10
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        Set Suite Variable  ${WHATSAPP_id2}   ${CUSERNAME0}
        ${virtualService2}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_vertual_ids}  ${wid${a}}

    END
    
    Log List   ${walkin_vertual_ids}
    ${walkin_vertual_len}=   Evaluate  len($walkin_vertual_ids)
    Set Suite Variable   ${walkin_vertual_len}
    ${walkin_token_len1}=   Evaluate  ${walkin_token_len}+${walkin_vertual_len}
    Set Suite Variable   ${walkin_token_len1}

    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertual_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-SubdomainLevelAnalytics-3
    [Documentation]   take tokens for normal service and teleservice for a provider and check subdomain level analytics

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names[2]}
    ${s_id1}=  Create Sample Service  ${SERVICE4}
    Set Test Variable  ${s_id1}

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

    comment  queue 2 for tokens

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id1}  ${v_s2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

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

    comment  take token
    ${ser_durtn}=   Random Int   min=0   max=0
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   10
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id1}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        ${resp}=  Get Waitlist By Id  ${token_wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_ids}  ${token_wid${a}}

    END

    Log List   ${walkin_ids}

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s2}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        ${resp}=  Get Waitlist By Id  ${token_wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_vertual_ids}  ${token_wid${a}}

    END

    Log List   ${walkin_vertual_ids}
    ${walkin_vertual_len1}=   Evaluate  len($walkin_vertual_ids)
    ${walkin_vertual_len1}=   Evaluate   ${walkin_vertual_len1}+${walkin_vertual_len}
    Set Suite Variable   ${walkin_vertual_len1}
    ${walkin_token_len2}=   Evaluate  len($walkin_ids)+len($walkin_vertual_ids)
    ${walkin_token_len2}=   Evaluate   ${walkin_token_len2}+${walkin_token_len1}+${walkin_token_len}
    Set Suite Variable   ${walkin_token_len2}

    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}    domainId=${domain_id}   subdomainId=${subdomain_id}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertual_ids1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-SubdomainLevelAnalytics-4
    [Documentation]   take online checkins, for a provider and check subdomain level analytics 
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins

    ${SERVICE10}=    Set Variable  ${ser_names[4]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}   ${s_id6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${online_checkins}=  Create List
    Set Suite Variable   ${online_checkins}

    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${online_checkins}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_checkins}

    ${online_vertualids}=  Create List
    Set Suite Variable   ${online_vertualids}

    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${consumerNote1}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        ${resp}=  Consumer Add To WL With Virtual Service  ${pid}  ${q_id1}  ${DAY}  ${v_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${online_vertualids}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${online_vertualids}
    ${online_token_len3}=   Evaluate  len($online_checkins)+len($online_vertualids)
    Set Suite Variable   ${online_token_len3}

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len3}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SubdomainLevelAnalytics-5
    [Documentation]   take online checkins for prepayment services and check analytics 
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE11}=    Set Variable  ${ser_names[5]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id7}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id7}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}  ${s_id7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${prepay_checkins}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${prepay_checkins}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${prepay_checkins}

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SubdomainLevelAnalytics-6
    [Documentation]   take checkins,for a provider and check subdomain level analytics for waitlistactions(started,cancelled)
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[6]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[7]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id6}  ${s_id7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log   ${waitlist_id[0]}
    ${len}=  Get Length  ${waitlist_id}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Waitlist By Id  ${waitlist_id[${a}]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[2]}

    END

    FOR   ${a}  IN RANGE   ${len2}   ${len}  

        ${desc}=   FakerLibrary.word
        ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
        ${resp}=  Waitlist Action Cancel  ${waitlist_id[${a}]}  ${cncl_resn}  ${desc}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${waitlist_id[${a}]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[4]}

    END


    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    
JD-TC-SubdomainLevelAnalytics-7
    [Documentation]   take checkins,for a provider and check subdomain level analytics for waitlistactions(done)
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[8]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[9]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id6}  ${s_id7}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${pid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log   ${waitlist_id[0]}
    ${len}=  Get Length  ${waitlist_id}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  Get Waitlist By Id  ${waitlist_id[${a}]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[5]}

    END

    # FOR   ${a}  IN RANGE   ${len2}   ${len}  

    #     ${desc}=   FakerLibrary.word
    #     ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    #     ${resp}=  Waitlist Action Cancel  ${waitlist_id[${a}]}  ${cncl_resn}  ${desc}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${resp}=  Get Waitlist By Id  ${waitlist_id[${a}]} 
    #     Log  ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Should Be Equal As Strings  ${resp.json()['waitlistStatus']}      ${wl_status[4]}

    # END


    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['DONE_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['DONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-SubdomainLevelAnalytics-8
    [Documentation]     take checkins, for a provider from consumer side and check subdomain level analytics after reschedule it
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    comment  Services for check-ins and appointments

    ${SERVICE10}=    Set Variable  ${ser_names[10]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[11]}
    ${s_id7}=  Create Sample Service  ${SERVICE11}
    Set Test Variable  ${s_id7}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}   ${s_id6}   ${s_id7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}
    
    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    # Log List   ${waitlist_id}

    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    ${DAY3}=  db.add_timezone_date  ${tz}  4  

    # change_system_time  1  30
    sleep  02s   

    Log   ${waitlist_id[0]}
    ${len}=  Get Length  ${waitlist_id}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}
     
        ${resp}=  Reschedule Waitlist  ${pid}  ${waitlist_id[${a}]}  ${DAY3}  ${q_id3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
 

JD-TC-SubdomainLevelAnalytics-9
    [Documentation]    take donations,and check subdomain level analytics for donation matrics
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[12]}
    # ${s_id6}=  Create Sample Donation  ${SERVICE10}  
    # Set Test Variable  ${s_id6}

    ${description}=  FakerLibrary.sentence
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=10000   max=50000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    ${service_duration}=   Random Int   min=1   max=3
    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}  1
    ${resp}=  Create Donation Service  ${SERVICE10}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${s_id6}  ${resp.json()}

    ${don_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname{$a}}  ${resp.json()['firstName']}
        Set Test Variable  ${lname{$a}}   ${resp.json()['lastName']}

        ${con_id}=  get_id  ${CUSERNAME${a}}
        Set Test Variable  ${con_id}
        ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
        ${don_amt}=   Random Int   min=1000   max=4000
        ${mod}=  Evaluate  ${don_amt}%${multiples[0]}
        ${don_amt}=  Evaluate  ${don_amt}-${mod}
        ${don_amt}=  Convert To Number  ${don_amt}  1
        ${don_amt_float}=  twodigitfloat  ${don_amt}
        Set Test Variable  ${don_amt}
        ${resp}=  Donation By Consumer  ${con_id}  ${s_id6}  ${lid}  ${don_amt}  ${fname{$a}}  ${lname{$a}}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        
        ${don_id}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${don_id${a}}  ${don_id[0]}

        ${resp}=  Get Consumer Donation By Id  ${don_id${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 

        Append To List   ${don_ids}  ${don_id${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    sleep  02s 

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${donationAnalyticsMetrics['DONATION_COUNT']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Get Subdomain Level Analytics  metricId=${donationAnalyticsMetrics['DONATION_TOTAL']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

       
JD-TC-SubdomainLevelAnalytics-10
    [Documentation]    take checkins for a provider and check subdomain level analytics for payment matrics
    # [Setup]  Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service    ${PUSERPH0}  AND  clear_appt_schedule   ${PUSERPH0}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[13]}
    ${s_id6}=  Create Sample Service  ${SERVICE10}
    Set Test Variable  ${s_id6}

    ${SERVICE11}=    Set Variable  ${ser_names[14]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id7}=  Create Sample Service with Prepayment   ${SERVICE11}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id7}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue  ${lid}  ${s_id6}  ${s_id7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${waitlist_id}=  Create List

    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    Log   ${waitlist_id[0]}
    ${len}=  Get Length  ${waitlist_id}
    ${len}=  Evaluate  ${len}/2
    ${len}=   Convert To Integer   ${len}

    FOR   ${a}  IN RANGE   ${len}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${cid}=  get_id  ${CUSERNAME${a}}
        Set Suite Variable   ${cid}
     
        ${resp}=  Get consumer Waitlist By Id  ${waitlist_id[${a}]}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

        ${resp}=  Make payment Consumer Mock  ${min_pre}  ${bool[1]}  ${waitlist_id[${a}]}  ${pid}  ${purpose[0]}  ${cid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${mer${a}}   ${resp.json()['merchantId']}  
        Set Suite Variable   ${payref${a}}  ${resp.json()['paymentRefId']}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    # ${tax1}=  Evaluate  ${servicecharge}*${gstpercentage[3]}
    # ${tax}=   Evaluate  ${tax1}/100
    # ${totalamt}=  Evaluate  ${servicecharge}+${tax}
    # ${totalamt}=  twodigitfloat  ${totalamt}
    # ${balamount1}=  Evaluate  ${totalamt}-${min_pre}
    # ${balamount}=  twodigitfloat  ${balamount1}

    ${balamount1}=  Evaluate  ${servicecharge}-${min_pre}
    ${balamount}=  twodigitfloat  ${balamount1}


    FOR   ${a}  IN RANGE   ${len}

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${fname}   ${resp.json()['firstName']}

        ${cid}=  get_id  ${CUSERNAME${a}}
        Set Suite Variable   ${cid}
     
        ${resp}=  Get consumer Waitlist By Id  ${waitlist_id[${a}]}  ${pid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}   waitlistStatus=${wl_status[0]}

        ${resp}=  Make payment Consumer Mock  ${balamount}  ${bool[1]}  ${waitlist_id[${a}]}  ${pid}  ${purpose[1]}  ${cid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  02s 
        ${resp}=  Get Bill By consumer  ${waitlist_id[${a}]}  ${pid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}   billPaymentStatus=${paymentStatus[2]}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  domainId=${domain_id}   subdomainId=${subdomain_id}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Subdomain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Subdomain Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Subdomain Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-SubdomainLevelAnalytics-11
    [Documentation]    Place an order By Consumer for Home Delivery both provider and consumer side.and get subdomain analytics(online order,walkin order,recieved order)
    
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_customer   ${PUSERNAME200}
    clear_Item   ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME200}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id1}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id1}  ${resp2.json()['serviceSubSector']['id']}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME200}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME20}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings   ${resp.status_code}    200
    
    ${online_order_ids}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${country_code}    Generate random string    2    0123456789
        ${country_code}    Convert To Integer  ${country_code}
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${EMPTY_List}=  Create List
        Set Suite Variable  ${EMPTY_List}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${online_order_ids}   ${orderid${a}}

        ${resp}=   Get Order By Id   ${accId}   ${walkin_order_ids[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    comment  Add customers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${walkin_order_ids}=  Create List
    FOR   ${a}  IN RANGE   9
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Suite Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Suite Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME200}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${walkin_order_ids}   ${orderid${a}}

        ${resp}=   Get Order by uid     ${walkin_order_ids[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    # change_system_time  2  0  
    sleep  02s   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['ONLINE_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      9
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['WALK_IN_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['WALK_IN_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      9
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['TOTAL_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['TOTAL_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      18
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['RECEIVED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['RECEIVED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      18
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


JD-TC-SubdomainLevelAnalytics-12
    [Documentation]    Place an order By Consumer for Home Delivery both provider and consumer side.and get subdomain analytics.(Aknowledged order,preapring,packing,confirmed)
    
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_customer   ${PUSERNAME200}
    clear_Item   ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME200}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id1}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id1}  ${resp2.json()['serviceSubSector']['id']}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME200}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}   ${orderStatuses[4]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[8]}   ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}  
    Set Suite Variable   ${StatusList}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${order_ids}=  Create List
    FOR   ${a}  IN RANGE   10
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${country_code}    Generate random string    2    0123456789
        ${country_code}    Convert To Integer  ${country_code}
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${EMPTY_List}=  Create List
        Set Suite Variable  ${EMPTY_List}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids}   ${orderid${a}}

        ${resp}=   Get Order By Id   ${accId}   ${order_ids[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    comment  Add customers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${order_ids1}=  Create List
    FOR   ${a}  IN RANGE   10
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Suite Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Suite Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME200}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids1}   ${orderid${a}}

        ${resp}=   Get Order by uid     ${order_ids1[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log   ${order_ids1[0]}
    ${len}=  Get Length  ${order_ids1}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[1]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[0]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[1]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[2]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[1]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[2]}

    END

    Log   ${order_ids[0]}
    ${len}=  Get Length  ${order_ids}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids[${a}]}    ${StatusList[3]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[2]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[3]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[4]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[3]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[4]}

    END


    # change_system_time  2  0  
    sleep  02s   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['ACKNOWLEDGED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['CONFIRMED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['CONFIRMED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['PREPARING_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['PREPARING_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['PACKING_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['PACKING_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


JD-TC-SubdomainLevelAnalytics-13
    
    [Documentation]    Place an order By Consumer for Home Delivery both provider and consumer side.and get subdomain analytics.(Payment required,ready for pickup,ready for shipment,Ready for delivery order)
    
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_customer   ${PUSERNAME200}
    clear_Item   ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME200}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id1}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id1}  ${resp2.json()['serviceSubSector']['id']}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME200}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}   ${orderStatuses[4]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[8]}   ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}  
    Set Suite Variable   ${StatusList}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${order_ids}=  Create List
    FOR   ${a}  IN RANGE   10
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${country_code}    Generate random string    2    0123456789
        ${country_code}    Convert To Integer  ${country_code}
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${EMPTY_List}=  Create List
        Set Suite Variable  ${EMPTY_List}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids}   ${orderid${a}}

        ${resp}=   Get Order By Id   ${accId}   ${order_ids[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    comment  Add customers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${order_ids1}=  Create List
    FOR   ${a}  IN RANGE   10
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Suite Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Suite Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME200}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids1}   ${orderid${a}}

        ${resp}=   Get Order by uid     ${order_ids1[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log   ${order_ids1[0]}
    ${len}=  Get Length  ${order_ids1}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[5]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[4]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[5]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[6]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[5]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[6]}

    END

    Log   ${order_ids[0]}
    ${len}=  Get Length  ${order_ids}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids[${a}]}    ${StatusList[7]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[6]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[7]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[8]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[7]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[8]}

    END


    # change_system_time  2  0  
    sleep  02s   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['PAYMENT_REQUIRED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['READY_FOR_PICKUP_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['READY_FOR_PICKUP_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 
    
    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['READY_FOR_SHIPMENT_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['READY_FOR_DELIVERY_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['READY_FOR_DELIVERY_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


JD-TC-SubdomainLevelAnalytics-14
    
    [Documentation]    Place an order By Consumer for Home Delivery both provider and consumer side.and get subdomain analytics.(Intransit order,completed , shipped ,canceled order)
    
    clear_queue    ${PUSERNAME200}
    clear_service  ${PUSERNAME200}
    clear_customer   ${PUSERNAME200}
    clear_Item   ${PUSERNAME200}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${accId}=  get_acc_id  ${PUSERNAME200}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id1}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id1}  ${resp2.json()['serviceSubSector']['id']}


    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME200}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}

    ${itemName1}=   FakerLibrary.name  

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode1}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.add_timezone_date  ${tz}  11  
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  30     
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=1   max=100
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity}=  Random Int  min=1   max=30

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50

    ${catalogName}=   FakerLibrary.name  

    ${catalogDesc}=   FakerLibrary.name 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5

    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}

    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}

    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}

    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
 
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   

    ${StatusList}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}  ${orderStatuses[3]}   ${orderStatuses[4]}  ${orderStatuses[5]}   ${orderStatuses[6]}   ${orderStatuses[7]}  ${orderStatuses[8]}   ${orderStatuses[9]}  ${orderStatuses[10]}   ${orderStatuses[11]}   ${orderStatuses[12]}  
    Set Suite Variable   ${StatusList}

    ${item1_Id}=  Create Dictionary  itemId=${item_id1}   
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${catalogItem1}
    
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
   
    ${far}=  Random Int  min=14  max=14
   
    ${soon}=  Random Int  min=1   max=1
   
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${order_ids}=  Create List
    FOR   ${a}  IN RANGE   10
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME${a}}   ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings   ${resp.status_code}    200
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${country_code}    Generate random string    2    0123456789
        ${country_code}    Convert To Integer  ${country_code}
        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${firstname}=  FakerLibrary.first_name
        Set Test Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${EMPTY_List}=  Create List
        Set Suite Variable  ${EMPTY_List}

        ${resp}=   Create Order For HomeDelivery   ${cookie}   ${accId}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids}   ${orderid${a}}

        ${resp}=   Get Order By Id   ${accId}   ${order_ids[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    comment  Add customers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${order_ids1}=  Create List
    FOR   ${a}  IN RANGE   10
        
        ${DAY1}=  db.add_timezone_date  ${tz}  12  
        ${C_firstName}=   FakerLibrary.first_name 
        ${C_lastName}=   FakerLibrary.name 
        ${C_num1}    Random Int  min=123456   max=999999
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${C_num1}
        Set Test Variable   ${CUSERPH${a}}   ${CUSERPH}
        Set Test Variable  ${C_email}  ${C_firstName}${CUSERPH${a}}.${test_mail}
        ${homeDeliveryAddress}=   FakerLibrary.name 
        ${city}=  FakerLibrary.city
        ${landMark}=  FakerLibrary.Sentence   nb_words=2 
        ${address}=  Create Dictionary   phoneNumber=${CUSERPH${a}}   firstName=${C_firstName}   lastName=${C_lastName}   email=${C_email}    address=${homeDeliveryAddress}   city=${city}   postalCode=${C_num1}    landMark=${landMark}   countryCode=${countryCodes[0]}
        Set Suite Variable  ${address}

        ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity}   max=${maxQuantity}
        ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
        Set Suite Variable  ${item_quantity1}
        ${firstname}=  FakerLibrary.first_name
        Set Suite Variable  ${email}  ${firstname}${CUSERNAME20}.${test_mail}
        ${orderNote}=  FakerLibrary.Sentence   nb_words=5
        Set Suite Variable  ${orderNote}

        ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME200}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid${a}}   ${cid${a}}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${orderid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${orderid${a}}  ${orderid[0]}

        Append To List   ${order_ids1}   ${orderid${a}}

        ${resp}=   Get Order by uid     ${order_ids1[${a}]} 
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log   ${order_ids1[0]}
    ${len}=  Get Length  ${order_ids1}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[9]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[8]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[9]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[10]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[9]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[10]}

    END

    Log   ${order_ids[0]}
    ${len}=  Get Length  ${order_ids}
    ${len2}=  Evaluate  ${len}/2
    ${len2}=   Convert To Integer   ${len2}

    FOR   ${a}  IN RANGE   ${len2}
     
        ${resp}=  Change Order Status   ${order_ids[${a}]}    ${StatusList[11]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[10]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[11]}

    END

    FOR   ${a}  IN RANGE   ${len2}  ${len}  
     
        ${resp}=  Change Order Status   ${order_ids1[${a}]}    ${StatusList[12]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  02s
        ${resp}=  Get Order Status Changes by uid    ${order_ids1[${a}]}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Should Be Equal As Strings  ${resp.json()[0]['orderStatus']}         ${StatusList[11]}
        # Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}         ${StatusList[12]}

    END


    # change_system_time  2  0  
    sleep  02s  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['ONLINE_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['COMPLETED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['COMPLETED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['IN_TRANSIT_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['SHIPPED_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['SHIPPED_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${orderAnalyticsMetrics['CANCEL_ORDER']}    domainId=${domain_id1}  subdomainId=${subdomain_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${orderAnalyticsMetrics['CANCEL_ORDER']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      5
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 


JD-TC-SubdomainLevelAnalytics-15
    [Documentation]   take checkins,for a provider and check subdomain level analytics brand new customers

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    Set Suite Variable   ${PUSERPH1}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH1}   AND  clear_service  ${PUSERPH1}  AND  clear_Item    ${PUSERPH1}  AND   clear_Coupon   ${PUSERPH1}   AND  clear_Discount  ${PUSERPH1}
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH1}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH1}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH1}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id2}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id2}  ${resp2.json()['serviceSubSector']['id']}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH1}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH1}+2000000000
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
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH1}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}


    FOR  ${i}  IN RANGE   5
        ${ser_names1}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names1}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names1[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id}

    ${SERVICE2}=    Set Variable  ${ser_names1[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id1}

    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names1[3]}
    ${s_id2}=  Create Sample Service  ${SERVICE4}
    Set Test Variable  ${s_id2}

    ${SERVICE5}=    Set Variable  ${ser_names1[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id3}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id3}

    comment  Services for appointments

    ${SERVICE7}=    Set Variable  ${ser_names1[6]}
    ${s_id4}=  Create Sample Service  ${SERVICE7}
    Set Test Variable  ${s_id4}

    ${SERVICE8}=    Set Variable  ${ser_names1[7]}
    ${min_pre1}=   Random Int   min=10   max=50
    ${servicecharge1}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre1}  ${servicecharge1}
    Set Test Variable  ${s_id5}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    comment  queue 2 for tokens

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id2}  ${s_id3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}


    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid1}   ${s_id4}   ${s_id5}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid1}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}   ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200


    comment  Add customers

    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+8067801111
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76060
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_N}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${PUSERNAME_N}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${PUSERNAME_N}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment  take check-ins

    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${PUSERNAME_N}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}


    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid}

    # ${resp}=  Get Waitlist By Id  ${wid}
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  10s 

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['NEW_CONSUMER_TOTAL']}    domainId=${domain_id2}   subdomainId=${subdomain_id2}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${tokenAnalyticsMetrics['NEW_CONSUMER_TOTAL']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      1
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['TOTAL_BRAND_NEW_TRANSACTIONS']}    domainId=${domain_id2}  subdomainId=${subdomain_id2}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}    domainId=${domain_id2}  subdomainId=${subdomain_id2}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['ANDROID_NEW_CONSUMER_COUNT']}    domainId=${domain_id2}  subdomainId=${subdomain_id2}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # change_system_date  -5
    # change_bill_cycle  ${eday}
    # ${day2}=  bill_cycle
    # ${resp}=   Encrypted Provider Login  ${ph}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Generate Invoice  ${pid}  monthly
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Get Invoices  NotPaid
    # Should Be Equal As Strings    ${resp.status_code}    200
   

JD-TC-SubdomainLevelAnalytics-16
    [Documentation]   take checkins for a provider and check subdomain level analytics android through (keywords)

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    Set Suite Variable   ${PUSERPH2}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH2}   AND  clear_service  ${PUSERPH2}  AND  clear_Item    ${PUSERPH2}  AND   clear_Coupon   ${PUSERPH2}   AND  clear_Discount  ${PUSERPH2}
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH2}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${domain_id3}  ${resp2.json()['serviceSector']['id']}
    Set Suite Variable  ${subdomain_id3}  ${resp2.json()['serviceSubSector']['id']}
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH2}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH2}+2000000000
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERPH2}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERPH2}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}


    FOR  ${i}  IN RANGE   5
        ${ser_names1}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names1}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names1[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id}

    ${SERVICE2}=    Set Variable  ${ser_names1[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id1}

    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names1[3]}
    ${s_id2}=  Create Sample Service  ${SERVICE4}
    Set Test Variable  ${s_id2}

    ${SERVICE5}=    Set Variable  ${ser_names1[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id3}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id3}

    comment  Services for appointments

    ${SERVICE7}=    Set Variable  ${ser_names1[6]}
    ${s_id4}=  Create Sample Service  ${SERVICE7}
    Set Test Variable  ${s_id4}

    ${SERVICE8}=    Set Variable  ${ser_names1[7]}
    ${min_pre1}=   Random Int   min=10   max=50
    ${servicecharge1}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre1}  ${servicecharge1}
    Set Test Variable  ${s_id5}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    comment  queue 2 for tokens

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id2}  ${s_id3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}


    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid1}   ${s_id4}   ${s_id5}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid1}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}   ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200


    comment  Add customers

    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+8067801118

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}
    ${resp}=  Android App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_N}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Activation  ${PUSERNAME_N}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${PUSERNAME_N}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Android App Consumer Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Android App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    comment  take check-ins

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${PUSERNAME_N}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid}

    # ${resp}=  Get Waitlist By Id  ${wid}
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    sleep  10s 

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['NEW_CONSUMER_TOTAL']}    domainId=${domain_id3}   subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${tokenAnalyticsMetrics['NEW_CONSUMER_TOTAL']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      54
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['TOTAL_BRAND_NEW_TRANSACTIONS']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['ANDROID_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['IOS_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # change_system_date  30
    # change_bill_cycle  ${eday}
    # ${day2}=  bill_cycle
    # ${resp}=   Encrypted Provider Login  ${ph}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Generate Invoice  ${pid}  monthly
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Get Invoices  NotPaid
    # Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-SubdomainLevelAnalytics-17
    [Documentation]   take checkins,for a provider and check subdomain level analytics brand new customers ios through 


    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names1[10]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id}

    ${SERVICE2}=    Set Variable  ${ser_names1[11]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id1}

    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names1[13]}
    ${s_id2}=  Create Sample Service  ${SERVICE4}
    Set Test Variable  ${s_id2}

    ${SERVICE5}=    Set Variable  ${ser_names1[14]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id3}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id3}

    comment  Services for appointments

    ${SERVICE7}=    Set Variable  ${ser_names1[16]}
    ${s_id4}=  Create Sample Service  ${SERVICE7}
    Set Test Variable  ${s_id4}

    ${SERVICE8}=    Set Variable  ${ser_names1[17]}
    ${min_pre1}=   Random Int   min=10   max=50
    ${servicecharge1}=   Random Int  min=100  max=200
    ${s_id5}=  Create Sample Service with Prepayment   ${SERVICE8}  ${min_pre1}  ${servicecharge1}
    Set Test Variable  ${s_id5}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    comment  queue 2 for tokens

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid1}  ${s_id2}  ${s_id3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}


    comment  schedule for appointment

    ${resp}=  Create Sample Schedule   ${lid1}   ${s_id4}   ${s_id5}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${EMPTY}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  3    3  ${lid1}  ${resp.json()['timeDuration']}  ${bool[1]}  ${s_id4}   ${s_id5}
    Should Be Equal As Strings  ${resp.status_code}  200


    comment  Add customers

    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+8067801113

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}
    ${resp}=  iphone App Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_N}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  iphone App Consumer Activation  ${PUSERNAME_N}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${PUSERNAME_N}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  iphone App Consumer Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  iphone App ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    comment  take check-ins

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${PUSERNAME_N}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid}

    # ${resp}=  Get Waitlist By Id  ${wid}
    # Log  ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  10s
    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['NEW_CONSUMER_TOTAL']}    domainId=${domain_id3}   subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${tokenAnalyticsMetrics['NEW_CONSUMER_TOTAL']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      54
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['TOTAL_BRAND_NEW_TRANSACTIONS']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['ANDROID_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}   subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${consumerAnalyticsMetrics['IOS_NEW_CONSUMER_COUNT']}    domainId=${domain_id3}  subdomainId=${subdomain_id3}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # change_system_date  30
    # change_bill_cycle  ${eday}
    # ${day2}=  bill_cycle
    # ${resp}=   Encrypted Provider Login  ${ph}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Generate Invoice  ${pid}  monthly
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Get Invoices  NotPaid
    # Should Be Equal As Strings    ${resp.status_code}    200







































***comment***

JD-TC-SubdomainLevelAnalytics-1
    [Documentation]   take checkins, tokens and appointments for a provider and check domain level analytics

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
    Set Suite Variable  ${subdomain_id}  ${resp2.json()['serviceSubSector']['id']}

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names}

    comment  Services for check-ins

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Test Variable  ${s_id}

    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id1}
    
    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
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
    Set Test Variable  ${v_s1}  ${resp.json()}

    comment  Services for tokens

    ${SERVICE4}=    Set Variable  ${ser_names[3]}
    ${s_id2}=  Create Sample Service  ${SERVICE4}
    Set Test Variable  ${s_id2}

    ${SERVICE5}=    Set Variable  ${ser_names[4]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id3}=  Create Sample Service with Prepayment   ${SERVICE5}  ${min_pre}  ${servicecharge}
    Set Test Variable  ${s_id3}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
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
    Set Test Variable  ${v_s2}  ${resp.json()}


    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id}  ${s_id1}  ${v_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    comment  queue 2 for tokens

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  50  ${lid}  ${s_id2}  ${s_id3}  ${v_s2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

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

    comment  take check-ins

    ${waitlist_ids}=  Create List
    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_ids}  ${wid${a}}

    END

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200


        Append To List   ${waitlist_ids}  ${wid${a}}

    END

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        Set Suite Variable  ${WHATSAPP_id2}   ${CUSERNAME0}
        ${virtualService2}=  Create Dictionary   ${CallingModes[1]}=${WHATSAPP_id2}

        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200


        Append To List   ${waitlist_ids}  ${wid${a}}

    END
    
    comment  take token

    ${ser_durtn}=   Random Int   min=0   max=0
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  ${ser_durtn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}   ${Empty}
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

        ${resp}=  Get Waitlist By Id  ${token_wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200


        Append To List   ${waitlist_ids}  ${token_wid${a}}

    END

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        ${resp}=  Get Waitlist By Id  ${token_wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200


        Append To List   ${waitlist_ids}  ${token_wid${a}}

    END

    FOR   ${a}  IN RANGE   9
            
        ${desc}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        ${resp}=  Provider Add To WL With Virtual Service  ${cid${a}}  ${v_s2}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${token_wid${a}}  ${wid[0]}
        ${tid}=  Get Dictionary Keys  ${resp.json()}
        Set Suite Variable  ${token_id${a}}  ${tid[0]}

        ${resp}=  Get Waitlist By Id  ${token_wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_ids}  ${token_wid${a}}

    END

   
    # change_system_time  2  0 
    sleep  02s  

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['frequency']}      DAILY
    # Should Be Equal As Strings  ${resp.json()['metricId']}       ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}      54
    # Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}      ${DAY1} 

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Subdomain Level Analytics   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  domainId=${domain_id}   subdomainId=${subdomain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
