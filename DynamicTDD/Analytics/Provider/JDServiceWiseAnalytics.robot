*** Settings ***
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
# Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Analytics
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
JD-TC-ServiceWiseAnalytics-1
    [Documentation]   take walkin checkins for a provider and check service wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
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
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
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
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

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

    ${SERVICE2}=    Set Variable  ${ser_names[1]}
    ${s_id2}=  Create Sample Service  ${SERVICE2}  maxBookingsAllowed=10
    Set Suite Variable  ${s_id2}

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
    ...  ${resp.json()['parallelServing']}   500  ${lid}  ${s_id}    ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    # ------------------- Add customers and take checkin  -------------------
    # comment  Add customers and take check-ins

    ${walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${walkin_waitlist_ids}

    ${service_count}=  Create List
    Set Suite Variable   ${service_count}
    
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
        Append To List   ${service_count}  ${wid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    Log List   ${walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    ${service_count_len}=   Evaluate  len($service_count)
    Set Suite Variable   ${service_count_len}

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

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-ServiceWiseAnalytics-2
    [Documentation]   take walkin checkins for another service for a provider and check service wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${service_count1}=  Create List
    Set Suite Variable   ${service_count1}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id2}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${service_count1}  ${wid${a}}

    END

    Log List   ${service_count1}

    # ${service_counts}=   Evaluate  len($service_count_len) + len($service_count_len)
    # Set Suite Variable   ${service_counts}

    ${service_count_len}=   Evaluate  len($service_count) + len($service_count1)
    Set Suite Variable   ${service_count_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-ServiceWiseAnalytics-3
    [Documentation]   take future walkin checkins for a provider and check service wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${FUT_DAY}=  db.add_timezone_date  ${tz}  5


    ${Future_count1}=  Create List
    Set Suite Variable   ${Future_count1}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id2}  ${q_id1}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${Future_count1}  ${wid${a}}

    END

    Log List   ${Future_count1}

    ${Future_count1}=   Evaluate  len($Future_count1)

    ${Future_service_count_len}=   Evaluate  len($service_count) + len($service_count1) + len($Future_count1)
    Set Suite Variable   ${Future_service_count_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${Future_service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${FUT_DAY}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${Future_count1}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${FUT_DAY}

    ${resp}=  Get Account Level Analytics  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${FUT_DAY}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${ServiceWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${Future_service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${FUT_DAY}