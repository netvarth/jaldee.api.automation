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

JD-TC-TeamLevelAnalytics-1
    [Documentation]   take checkins for normal service  for a provider and check Get Team Level Analytics

    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+822550
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${accid}=   get_acc_id   ${MUSERNAME_E}
    Set Suite Variable  ${accid}
    ${DAY1}=  get_date
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
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  45
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

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=25
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${kw_status}'=='True'
    END
    Set Suite Variable  ${ser_names}

    ${SERVICE1}=    Set Variable  ${ser_names[0]}
    ${desc}=   FakerLibrary.word
    ${total_amount}=  Random Int  min=100  max=500
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   2   ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}   ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.get_time
    ${end_time}=    add_time  2  00 
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=5   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

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

    comment  take check-ins

    ${walkin_ids}=  Create List
    Set Suite Variable   ${walkin_ids}
    FOR   ${a}  IN RANGE   5
            
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_ids}  ${wid${a}}

    END
    Log List   ${walkin_ids}
    ${walkin_token_len}=   Evaluate  len($walkin_ids)
    Set Suite Variable   ${walkin_token_len}

    ${USERNAME1}=  Evaluate  ${MUSERNAME_E}+110044
    Set Suite Variable  ${USERNAME1}
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

    ${whpnum}=  Evaluate  ${MUSERNAME_E}+77487
    ${tlgnum}=  Evaluate  ${MUSERNAME_E}+65874

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${USERNAME1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${USERNAME2}=  Evaluate  ${MUSERNAME_E}+11458721
    Set Suite Variable  ${USERNAME2}
    clear_users  ${USERNAME2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${USERNAME2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${USERNAME2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    
     ${team_name}=  FakerLibrary.name
    ${team_size}=  Random Int  min=10  max=50
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id1}  ${resp.json()}

    ${team_name1}=  FakerLibrary.name
    ${desc1}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id2}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id1}  ${u_id2}

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${user_ids}=  Create List  ${u_id1}  ${u_id2} 

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${assign_ids}=  Create List
    Set Suite Variable   ${assign_ids}

    FOR   ${a}  IN RANGE   5
            
        ${resp}=   Assign Team To Checkin  ${walkin_ids[${a}]}  ${t_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${walkin_ids[${a}]}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${assign_ids}  ${walkin_ids[${a}]}

    END
    ${assign_ids_len}=   Evaluate  len($assign_ids)
    Set Suite Variable   ${assign_ids_len}

    ${resp}=  Flush Analytics Data to DB
    sleep  02s   

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}    dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-TeamLevelAnalytics-2
    [Documentation]   take checkins for teleservice for a provider and check Get Team Level Analytics

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    ${accid}=   get_acc_id   ${MUSERNAME_E}
   
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

    ${resp}=  Create virtual Service with dept  ${SERVICE3}   ${description}   2   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${Total1}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v_s1}  ${resp.json()}

    comment  queue 1 for checkins

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${eTime1}=  add_time   1  30
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

    ${assign_ids}=  Create List
    Set Suite Variable   ${assign_ids}

    FOR   ${a}  IN RANGE   10
            
        ${resp}=   Assign Team To Checkin  ${walkin_vertual_ids[${a}]}   ${t_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${walkin_vertual_ids[${a}]} 
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${assign_ids}  ${walkin_vertual_ids[${a}]} 

    END
    ${assign_ids_len}=   Evaluate  len($assign_ids)
    Set Suite Variable   ${assign_ids_len}

    ${walkin_token_len1}=   Evaluate  ${walkin_token_len}+${assign_ids_len}
    Set Suite Variable   ${walkin_token_len1}

    # change_system_time  2  0 
    sleep  02s  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TOTAL_FOR_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['WEB_TOKENS']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}    accId=${accid}  userId=${u_id1}   teamId=${t_id1}     dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['TELE_SERVICE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_vertual_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-TeamLevelAnalytics-3
    [Documentation]   take online checkins, for a provider and check Get Team Level Analytics 
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    
    ${accid}=   get_acc_id   ${MUSERNAME_E}
   
    comment  Services for check-ins

    ${SERVICE10}=    Set Variable  ${ser_names[4]}
    ${desc}=   FakerLibrary.word
    ${total_amount}=  Random Int  min=100  max=500
    ${resp}=  Create Service Department  ${SERVICE10}  ${desc}   2   ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}   ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id6}  ${resp.json()}

    comment  queue 1 for checkins

    ${resp}=  Sample Queue   ${lid}   ${s_id6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}

    ${online_checkins}=  Create List
    Set Suite Variable   ${online_checkins}

    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${accid}  ${q_id3}  ${DAY}  ${s_id6}  ${cnote}  ${bool[0]}  ${self} 
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
        
        ${DAY}=  get_date
        ${consumerNote1}=   FakerLibrary.word
        ${virtualService}=  Create Dictionary   ${CallingModes[0]}=${ZOOM_id0}
        ${resp}=  Consumer Add To WL With Virtual Service  ${accid}  ${q_id1}  ${DAY}  ${v_s1}  ${consumerNote1}  ${bool[0]}  ${virtualService}   ${self} 
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

    ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${online_assign_ids}=  Create List
    Set Suite Variable   ${online_assign_ids}

    FOR   ${a}  IN RANGE   9
            
        ${resp}=   Assign Team To Checkin  ${online_checkins[${a}]}   ${t_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_checkins[${a}]} 
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${online_assign_ids}  ${online_checkins[${a}]} 

    END
    ${assign_ids_len}=   Evaluate  len($assign_ids)
    Set Suite Variable   ${assign_ids_len}

    FOR   ${a}  IN RANGE   9
            
        ${resp}=   Assign Team To Checkin  ${online_vertualids[${a}]}   ${t_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${online_vertualids[${a}]} 
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${online_assign_ids}  ${online_vertualids[${a}]} 

    END
    ${assign_ids_len}=   Evaluate  len($online_assign_ids)
    Set Suite Variable   ${assign_ids_len}


    Log List   ${online_vertualids}
    ${online_token_len3}=   Evaluate  len($online_checkins)+len($online_vertualids)
    Set Suite Variable   ${online_token_len3}

    ${checkedin_token_len1}=   Evaluate  ${walkin_vertual_len}+${online_token_len3}
    Set Suite Variable   ${checkedin_token_len1}

    # change_system_time  1  30
    sleep  02s   

    # ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${online_token_len3}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${checkedin_token_len1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-TeamLevelAnalytics-4
    [Documentation]   take online checkins for prepayment services and check analytics 
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE11}=    Set Variable  ${ser_names[5]}
    ${desc}=   FakerLibrary.word
    ${total_amount}=  Random Int  min=100  max=500
    ${min_pre}=   Random Int   min=10   max=50
    ${resp}=  Create Service Department  ${SERVICE11}  ${desc}   2   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${total_amount}  ${bool[1]}  ${bool[0]}   ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id7}  ${resp.json()}


    comment  queue 1 for checkins

    ${resp}=  Sample Queue   ${lid}  ${s_id7} 
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
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${accid}  ${q_id3}  ${DAY}  ${s_id7}  ${cnote}  ${bool[0]}  ${self} 
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

    ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${assign_ids}=  Create List
    Set Suite Variable   ${assign_ids}

    FOR   ${a}  IN RANGE   10
            
        ${resp}=   Assign Team To Checkin  ${walkin_vertual_ids[${a}]}  ${t_id2}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${walkin_vertual_ids[${a}]} 
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${prepay_checkins}  ${walkin_vertual_ids[${a}]} 

    END
    ${assign_ids_len}=   Evaluate  len($prepay_checkins)
    Set Suite Variable   ${assign_ids_len}


    # change_system_time  1  30
    sleep  02s   

    # ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ONLINE_TOKEN']}  
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Get Team Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_COUNT']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${prepay_checkins}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics  metricId=${paymentAnalyticsMetrics['PRE_PAYMENT_TOTAL']}  accId=${accid}  userId=${u_id1}   teamId=${t_id1}   dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-TeamLevelAnalytics-5
    [Documentation]   take checkins,for a provider and check Get Team Level Analytics for waitlist actions
    # [Setup]  Run Keywords  clear_queue  ${MUSERNAME_E}   AND  clear_appt_schedule   ${MUSERNAME_E}

    ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Services for check-ins 

    ${SERVICE11}=    Set Variable  ${ser_names[6]}
    ${desc}=   FakerLibrary.word
    ${total_amount}=  Random Int  min=100  max=500
    ${resp}=  Create Service Department  ${SERVICE11}  ${desc}   2   ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}   ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id8}  ${resp.json()}

    ${SERVICE12}=    Set Variable  ${ser_names[7]}
    ${desc}=   FakerLibrary.word
    ${total_amount}=  Random Int  min=100  max=500
    ${resp}=  Create Service Department  ${SERVICE12}  ${desc}   2   ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${total_amount}  ${bool[0]}  ${bool[0]}   ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id9}  ${resp.json()}


    comment  queue 1 for checkins

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.get_time
    ${end_time}=    add_time  2  00 
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=10   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}  ${capacity}  ${lid}  ${s_id8}  ${s_id9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}   ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${waitlist_id}=  Create List
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${accid}  ${q_id3}  ${DAY}  ${s_id8}  ${cnote}  ${bool[0]}  ${self} 
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
    
    FOR   ${a}  IN RANGE   9
    
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  get_date
        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${accid}  ${q_id3}  ${DAY}  ${s_id9}  ${cnote}  ${bool[0]}  ${self} 
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

    # change_system_time  1  30
    sleep  02s   

    ${resp}=   Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    FOR   ${a}  IN RANGE   9
            
        ${resp}=   Assign Team To Checkin  ${walkin_vertual_ids[${a}]}   ${t_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Waitlist By Id  ${walkin_vertual_ids[${a}]} 
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${prepay_checkins}  ${walkin_vertual_ids[${a}]} 

    END
    ${assign_ids_len}=   Evaluate  len($prepay_checkins)
    Set Suite Variable   ${assign_ids_len}



    ${resp}=  Flush Analytics Data to DB

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['STARTED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Team Level Analytics  metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  userId=${u_id}   accId=${accid}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=DAILY
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  frequency=DAILY   metricId=${tokenAnalyticsMetrics['CANCELLED_TOKEN']}  
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${len2}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}






















