*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Jaldee Channel Analytics
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${count}       ${10}
${count1}      ${15}
${count2}      ${4}
${self}        0
${CUSERPH}     ${CUSERNAME}
${start}       11
${def_amt}     0.0
&{ioscons_headers}       Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=CONSUMER_APP 

*** Test Cases ***


JD-TC-JaldeeChannelAnalytics-1

    [Documentation]  check JALDEE_CHANNEL_TOKENS.

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
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
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
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  db.add_timezone_time  ${tz}   5  45
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
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Sample Queue   ${lid}   ${s_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

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

    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${s_id2}=  Create Sample Service  ${SERVICE2}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id2}

    comment  queue 1 for checkins    

    ${resp}=  Sample Queue   ${lid}   ${s_id2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time_by_timezone  ${tz}
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id2}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${time_now}  ${eTime1}
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${waitlist_ids}=  Create List
    Set Suite Variable   ${waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  App Consumer Login  ${ioscons_headers}  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${cnote}=   FakerLibrary.word
        ${resp}=  App Add To Waitlist Consumers  ${ioscons_headers}  ${pid}  ${q_id1}  ${DAY}  ${s_id}  ${cnote}  ${bool[0]}  ${self} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${cwid${a}}  ${wid[0]}

        Append To List   ${waitlist_ids}  ${cwid${a}}

        ${resp}=  App Consumer Logout  ${ioscons_headers}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    Log List   ${waitlist_ids}

    FOR   ${a}  IN RANGE   ${count}
    
        ${resp}=  App Consumer Login  ${ioscons_headers}  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=  App Get consumer Waitlist By Id  ${ioscons_headers}  ${cwid${a}}  ${pid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  App Consumer Logout  ${ioscons_headers}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}= Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ios_token_len}=  Evaluate  len($waitlist_ids) 
    Set Suite Variable   ${ios_token_len}
       
    sleep  01s
    # sleep  05m
    
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['JALDEE_CHANNEL_TOKENS']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     