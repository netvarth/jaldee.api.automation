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
Variables         /ebs/TDD/varfiles/musers.py
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

JD-TC-UserLevelAnalytics-1
    [Documentation]   take checkins for normal service for a provider and check user level analytics

     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+844550
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200    
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${accid}=   get_acc_id   ${MUSERNAME_E}
     Set Suite Variable  ${accid} 
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
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
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
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
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+58738821
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${pin}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     ${employee_id}=  FakerLibrary.last_name

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
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
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    Set Test Variable  ${s_id}

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  25  ${lid}  ${u_id}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

     ${resp}=  Update User Search Status  ${toggle[0]}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User Search Status  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  True

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
    
    comment  take check-ins

    ${walkin_ids}=  Create List
    Set Suite Variable   ${walkin_ids}
    FOR   ${a}  IN RANGE   10
            
        ${desc}=   FakerLibrary.word

        ${resp}=  Add To Waitlist By User  ${cid${a}}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid${a}} 
        Log   ${resp.json()}
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
    sleep  042s   

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-UserLevelAnalytics-2
    [Documentation]   take checkins for teleservice for a provider and check user level analytics

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME_E}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${resp}=  Update Virtual Calling Mode   ${CallingModes[0]}  ${ZOOM_id0}   ACTIVE  ${instructions1}   ${CallingModes[1]}  ${MUSERNAME_E}   ACTIVE   ${instructions2}
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
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME_E}
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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  25  ${lid}  ${u_id}  ${v_s1} 
    Log  ${resp.json()}
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

        ${resp}=  Provider Add To WL With Virtual Service For User   ${u_id}   ${cid${a}}  ${v_s1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService}   ${cid${a}}
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

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As StTOTAL_FOR_TOKENrings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}    userId=${u_id}   accId=${accid}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertual_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-UserLevelAnalytics-3
    [Documentation]   take online checkins, for a provider and check user level analytics 
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins

    ${SERVICE10}=    Set Variable  ${ser_names[4]}
    ${s_id6}=  Create Sample Service For User  ${SERVICE10}  ${dep_id}  ${u_id}
    Set Test Variable  ${s_id6}

    comment  queue 1 for checkins
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${u_id}  ${s_id6} 
    Log  ${resp.json()}
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
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${u_id}  ${self}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
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
        ${resp}=  Consumer Add To WL With Virtual Service For User  ${accid}  ${q_id1}  ${DAY}  ${v_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   ${u_id} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
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

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len3}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLevelAnalytics-4
    [Documentation]   take online checkins for prepayment services and check analytics 
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE11}=    Set Variable  ${ser_names[5]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${min_pre}=   Random Int   min=10   max=50
    ${resp}=  Create Service For User  ${SERVICE11}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${amt}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id7}  ${resp.json()}

    comment  queue 1 for checkins

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${u_id}  ${s_id7} 
    Log  ${resp.json()}
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
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${u_id}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
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

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLevelAnalytics-5
    [Documentation]   take checkins,for a provider and check user level analytics for waitlist actions
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_service    ${MUSERNAME_E}  AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins  

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

    comment  queue 1 for checkins
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  20  ${lid}  ${u_id}  ${s_id6}  ${s_id7} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}


    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${u_id}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
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
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${u_id}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
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

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


    
JD-TC-UserLevelAnalytics-6
    [Documentation]   take checkins,for a provider and check user level analytics for waitlistactions
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_service    ${MUSERNAME_E}  AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[8]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE10}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id6}  ${resp.json()}

    ${SERVICE11}=    Set Variable  ${ser_names[9]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE11}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id7}  ${resp.json()}

    comment  queue 1 for checkins
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${u_id}  ${s_id6}  ${s_id7} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}


    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${u_id}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${waitlist_id}  ${cwid${a}}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_id}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
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

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['DONE_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['DONE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UserLevelAnalytics-7
    [Documentation]     take checkins, for a provider from consumer side and check user level analytics after reschedule it
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_service    ${MUSERNAME_E}  AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE10}=    Set Variable  ${ser_names[10]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE10}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id6}  ${resp.json()}

    ${SERVICE11}=    Set Variable  ${ser_names[11]}
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=1  max=5
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${resp}=  Create Service For User  ${SERVICE11}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id7}  ${resp.json()}

    comment  queue 1 for checkins
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  15  ${lid}  ${u_id}  ${s_id6}  ${s_id7} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}


     ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   8
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumer For User  ${accid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${u_id}  ${self} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${accid}   
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

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
     
        ${resp}=  Reschedule Waitlist  ${accid}  ${waitlist_id[${a}]}  ${DAY3}  ${q_id3}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['RESCHEDULED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}
 

JD-TC-UserLevelAnalytics-8
    [Documentation]    signup  a consumer and take checkins for normal for a provider and check user level analytics for brand new customer

     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_F}=  Evaluate  ${MUSERNAME}+884153
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_F}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_F}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200    
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_F}${\n}
     Set Suite Variable  ${MUSERNAME_F}
     ${accid1}=   get_acc_id   ${MUSERNAME_F}
     Set Suite Variable  ${accid1} 
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_F}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_F}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
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
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
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
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id1}  ${resp.json()['departments'][0]['departmentId']}

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+58738823
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${pin}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     ${employee_id}=  FakerLibrary.last_name

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

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

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id1}
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
        ${ser_names}=  FakerLibrary.Words  	nb=5
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names}

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id1}  ${u_id1}
    Set Test Variable  ${s_id}

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  25  ${lid}  ${u_id1}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

     ${resp}=  Update User Search Status  ${toggle[0]}  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User Search Status  ${u_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  True

    comment  Add customer

    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+8067801116
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76061
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.ynwtest@netvarth.com
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

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${PUSERNAME_N}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  04s   

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${consumerAnalyticsMetrics['NEW_CONSUMER_TOTAL']}  userId=${u_id1}   accId=${accid1}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get User Level Analytics   metricId=${consumerAnalyticsMetrics['TOTAL_BRAND_NEW_TRANSACTIONS']}    userId=${u_id1}   accId=${accid1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get User Level Analytics   metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}    userId=${u_id1}   accId=${accid1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-UserLevelAnalytics-9
    [Documentation]   take checkins, tokens and appointments for a provider and check user level analytics brand new customers android through 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id1}  ${u_id1}
    Set Test Variable  ${s_id}

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  25  ${lid}  ${u_id1}  ${s_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+8067801115
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.ynwtest@netvarth.com
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

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${PUSERNAME_N}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  04s   

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Level Analytics  metricId=${consumerAnalyticsMetrics['NEW_CONSUMER_TOTAL']}  userId=${u_id1}   accId=${accid1}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get User Level Analytics   metricId=${consumerAnalyticsMetrics['TOTAL_BRAND_NEW_TRANSACTIONS']}    userId=${u_id1}   accId=${accid1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get User Level Analytics   metricId=${consumerAnalyticsMetrics['ANDROID_NEW_CONSUMER_COUNT']}    userId=${u_id1}   accId=${accid1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   


























***comment***
JD-TC-UserLevelAnalytics-9
    [Documentation]    take donations,and check domain level analytics for donation matrics
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

    ${resp}=  Get Domain Level Analytics  metricId=${donationAnalyticsMetrics['DONATION_COUNT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Get Domain Level Analytics  metricId=${donationAnalyticsMetrics['DONATION_TOTAL']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

       
JD-TC-UserLevelAnalytics-10
    [Documentation]    take checkins for a provider and check domain level analytics for payment matrics
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

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_COUNT']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Domain Level Analytics  metricId=${paymentAnalyticsMetrics['BILL_PAYMENT_TOTAL']}  domainId=${domain_id}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
